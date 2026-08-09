## Why

Race and medal locations are entered as four free-text fields — country, province, city,
district (Jira MW-9). Nothing constrains the values, so one place becomes many strings:
`復興區` / `Fuxing` / `Fuxing District` / `Fuxing Dist.` all name the same location and none
of them match each other. Every location is retyped from scratch, and typos are silent.

The fix is a place picker, but the field layout is also wrong for where the product is
going. `Place`'s four fields mirror `CLPlacemark`, which iOS 26 has moved away from —
`CLGeocoder` is deprecated, `CLPlacemark` soft-deprecated, and `MKMapItem.placemark`
deprecated in favour of representations that return display strings with no `locality` or
`subLocality` equivalent. More importantly, the same Firestore data is intended for future
web, admin web, and Android clients, whose geocoders (Google Places, Mapbox) return
*different* strings for the same place. A schema built on either platform's display strings
cannot be grouped or queried consistently across all of them.

## What Changes

- **BREAKING** — reshape `Place` around a provider-neutral canonical core:

  | Field | Type | Notes |
  | --- | --- | --- |
  | `countryCode` | `String` | ISO 3166-1 alpha-2 (`"TW"`) — the only canonical field |
  | `city` | `String` | provider's `locality`: `"田中鎮"`, `"Portland"` — display only |
  | `region` | `String?` | provider's `administrativeArea`: `"彰化縣"`, `"OR"` — display only |

  Locations are recorded at **area level**. Exact position is deliberately not stored: a
  race's precise start line lives on its official site, and nothing in the app displays or
  reads a coordinate.

- **Store a country code, not a country name.** ISO 3166-1 is emitted by every geocoding
  provider and rendered locally by every platform (`Locale.localizedString(forRegionCode:)`,
  `Intl.DisplayNames`, `Locale.displayCountry`), so one stored value serves all clients in
  all languages. A stored country name could not.
- **`formatted` becomes computed, not stored.** Display rules can then change per platform,
  and per locale, without a migration or stale strings in Firestore.
- **Drop the `district` field.** It is redundant, not sacrificed: the spike showed a
  provider's `locality` already carries that level. 田中馬拉松 — colloquially the "田中"
  marathon, actually held in 彰化縣 — stores as `city: "田中鎮"`, `region: "彰化縣"`, so both
  the name people use and the county it sits in survive. Sub-locality is also the least
  consistent field across providers (Apple `subLocality`, Google `sublocality`, Mapbox
  `neighborhood` routinely disagree), so a dedicated field for it would not have been
  portable anyway.
- **Add a search-based place picker, and make it the only way in.** A tappable location row
  opens a sheet with a search field and live results; selecting one fills the location. There
  is no hand-typed fallback: free text would reintroduce the very drift this change removes,
  and unlike a rejected search result a typed value persists.
- **Normalize to city level.** Where a provider returns a district or township whose parent
  is itself the city — 復興區 within 桃園市, 田中鎮 within 彰化縣 — the parent is recorded and
  the sub-unit dropped, so one place yields one value however precisely it was searched.
- **Confine MapKit to one file.** A `PlaceSearchService` protocol with a
  `MapKitPlaceSearchService` implementation is the only file importing MapKit; MapKit types
  never escape it. When Apple removes the deprecated APIs it reads, one Swift file changes
  and the Firestore schema does not move — so future web and Android clients are never
  disturbed by an Apple deprecation.
- **No compatibility path.** `Place` decodes only the current shape; records written by
  1.0.0–1.1.0 do not load. Only three exist and they are updated by hand, so a permanent
  reader for the old shape — a custom decoder, a country-name-to-ISO lookup across four
  locales, and an alias table — would have been ~50 lines and 10 tests kept forever to read
  data that can be retyped in minutes.
- **Collapse two duplicate views into one.** `EditRaceLocationSection` and
  `EditMedalLocationSection` are byte-identical apart from their type names; both are
  replaced by a single shared `EditPlaceSection`.

## Capabilities

### New Capabilities
- `place-entry`: how a user specifies where a race or medal took place — the canonical
  cross-platform shape of a place, and how one is searched for and selected.

### Modified Capabilities
- `races`: the Race Management requirement enumerates location as
  "(country, optional province, city, optional district)". That enumeration is replaced by a
  reference to the `place-entry` capability, which now owns the shape.

<!-- `medals` is deliberately NOT modified: its requirement refers to "location" abstractly
     and stays true under the new shape. Only `races` names the four fields explicitly. -->

## Impact

- **BREAKING (data), in both directions:** on `races/{id}` and `users/{uid}/medals/{id}` the
  `location` map is **renamed to `place`** and reshaped, from
  `{country, province, city, district}` to `{countryCode, city, region?}`. Build 1.1.0 cannot
  read the new shape, and this build cannot read the old one. Because `fetchRaces`/`fetchMedals`
  decode with `try` inside a `map`, a single stale record fails the *entire* fetch, so the three
  existing records must be updated as part of shipping. Ship as a version bump, not a silent
  update.
- **New:** `Models/Shared/Place.swift` and `Models/Shared/PlaceSuggestion.swift`;
  `Services/PlaceSearchService.swift` and `Services/MapKitPlaceSearchService.swift`;
  `Shared/Components/PlacePicker/` (`PlacePickerView`, `PlacePickerViewModel`);
  `Shared/Components/Section/EditPlaceSection.swift`; and the tests `PlaceTests`,
  `PlaceNormalizationTests`, `PlacePickerViewModelTests`, plus the first test double,
  `MedalWallTests/Support/StubPlaceSearchService.swift`.
- **Deleted:** `Models/Shared/GeoLocation.swift` and `GeoLocationTests.swift` (replaced by
  `Place`), `EditRaceLocationSection.swift` and `EditMedalLocationSection.swift` (replaced by
  one shared section), and `Shared/UIModels/CountryOption.swift` (manual entry removed).
- **Edited:** `Race.swift` and `Medal.swift` (the `location` property becomes `place`), both
  edit ViewModels and their views, `AppError.swift`, `Race+SampleData`, `Medal+SampleData`,
  eight existing test files, and `project.pbxproj` — new sources must be added to the
  `MedalWallTests` membership exceptions, since the project compiles a curated list of app
  sources into the test target.
- **Display sites:** six call `place.formatted` — `RaceList`, `RaceDetailView`,
  `RaceDetailHeroSection`, `MedalDetailView`, `MedalDetailHeroSection`, and
  `RaceEntryPicker/RaceEntryList`. `formatted` stays a computed property, so none of them
  changed in what they render; they were touched only by the `location` → `place` rename.
  Presentation components downstream of them, such as `RaceRow`, had their `location:`
  parameter renamed to `place:` for the same reason.
- **No new permissions.** Search needs no location authorization, so no map view and no
  `NSLocationWhenInUseUsageDescription`.
- **Dependencies:** MapKit is a first-time addition; a system framework, no third-party
  packages.
- **Out of scope:** map-based pin placement, storing coordinates, and any map view of
  recorded locations. Should a map ever be wanted, approximate coordinates can be
  re-geocoded from the stored `city` / `region` / `countryCode`, which is all a
  country-zoom map would show.
