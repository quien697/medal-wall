## Why

Race and medal locations are entered as four free-text fields — country, province, city,
district (Jira MW-9). Nothing constrains the values, so one place becomes many strings:
`復興區` / `Fuxing` / `Fuxing District` / `Fuxing Dist.` all name the same location and none
of them match each other. Every location is retyped from scratch, and typos are silent.

The fix is a place picker, but the field layout is also wrong for where the product is
going. `GeoLocation`'s four fields mirror `CLPlacemark`, which iOS 26 has moved away from —
`CLGeocoder` is deprecated, `CLPlacemark` soft-deprecated, and `MKMapItem.placemark`
deprecated in favour of representations that return display strings with no `locality` or
`subLocality` equivalent. More importantly, the same Firestore data is intended for future
web, admin web, and Android clients, whose geocoders (Google Places, Mapbox) return
*different* strings for the same place. A schema built on either platform's display strings
cannot be grouped or queried consistently across all of them.

## What Changes

- **BREAKING** — reshape `GeoLocation` around a provider-neutral canonical core:

  | Field | Type | Notes |
  | --- | --- | --- |
  | `countryCode` | `String` | ISO 3166-1 alpha-2 (`"TW"`) — the canonical grouping key |
  | `city` | `String` | `"Taoyuan"` |
  | `region` | `String?` | `"Oregon"` / `"British Columbia"`; `nil` where meaningless |
  | `latitude` | `Double?` | |
  | `longitude` | `Double?` | |

- **Store a country code, not a country name.** ISO 3166-1 is emitted by every geocoding
  provider and rendered locally by every platform (`Locale.localizedString(forRegionCode:)`,
  `Intl.DisplayNames`, `Locale.displayCountry`), so one stored value serves all clients in
  all languages. A stored country name could not.
- **`formatted` becomes computed, not stored.** Display rules can then change per platform,
  and per locale, without a migration or stale strings in Firestore.
- **Drop `district`.** Coordinates supersede it — exact, provider-neutral, and free of
  spelling variants — and sub-locality is the least consistent field across providers
  (Apple `subLocality`, Google `sublocality`, Mapbox `neighborhood` routinely disagree).
- **Add a search-based place picker.** A tappable location row opens a sheet with a search
  field and live results; selecting one fills the location. Manual entry stays available, so
  offline use and places the provider does not know still work — the picker accelerates
  entry, it never becomes the only way in.
- **Confine MapKit to one file.** A `PlaceSearchService` protocol with a
  `MapKitPlaceSearchService` implementation is the only file importing MapKit; MapKit types
  never escape it. When Apple removes the deprecated APIs it reads, one Swift file changes
  and the Firestore schema does not move — so future web and Android clients are never
  disturbed by an Apple deprecation.
- **Migrate by lenient decode, not a batch job.** Records written by 1.0.0–1.1.0 decode by
  mapping legacy `city` → `city`, `province` → `region`, and reverse-looking-up the legacy
  country name to an ISO code, with coordinates `nil`. Records upgrade as they are re-saved.
- **Collapse two duplicate views into one.** `EditRaceLocationSection` and
  `EditMedalLocationSection` are byte-identical apart from their type names; both are
  replaced by a single shared `EditLocationSection`.

## Capabilities

### New Capabilities
- `location-entry`: how a user specifies where a race or medal took place — the canonical
  cross-platform shape of a location, place search and selection, manual fallback, and
  how previously stored locations are read.

### Modified Capabilities
- `races`: the Race Management requirement enumerates location as
  "(country, optional province, city, optional district)". That enumeration is replaced by a
  reference to the `location-entry` capability, which now owns the shape.

<!-- `medals` is deliberately NOT modified: its requirement refers to "location" abstractly
     and stays true under the new shape. Only `races` names the four fields explicitly. -->

## Impact

- **BREAKING (data):** the `location` map on `races/{id}` and `users/{uid}/medals/{id}`
  changes shape. The new build reads old records via lenient decode, but **build 1.1.0
  cannot read records written by this change** — `country` and `city` are required there and
  `countryCode`/`region` are unknown to it. Ship as a version bump, not a silent update.
- **New:** `Services/PlaceSearchService.swift` (protocol + `MapKitPlaceSearchService`),
  `Features/LocationPicker/` (`LocationPickerView`, `LocationPickerViewModel`),
  `Shared/Components/Section/EditLocationSection.swift`, `Models/Shared/PlaceSuggestion.swift`.
- **Edited:** `Models/Shared/GeoLocation.swift`, `EditRaceViewModel`, `EditMedalViewModel`
  (including the race-entry copy path), `EditRaceView`, `EditMedalView`,
  `Race+SampleData`, `Medal+SampleData`, `GeoLocationTests`.
- **Deleted:** `EditRaceLocationSection.swift`, `EditMedalLocationSection.swift`.
- **Unchanged:** all six display sites call `location.formatted`, which is preserved as a
  computed property.
- **No new permissions.** Search needs no location authorization, so no map view and no
  `NSLocationWhenInUseUsageDescription`.
- **Dependencies:** MapKit and CoreLocation are first-time additions; both are system
  frameworks, no third-party packages.
- **Out of scope:** map-based pin placement and a map view of recorded locations (the stored
  coordinates make both possible later); backfilling coordinates onto pre-existing records.
