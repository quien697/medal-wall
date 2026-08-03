## Context

`GeoLocation` today is four free-text strings — `country`, `province`, `city`, `district` —
bound directly to `TextField`s in two byte-identical views, `EditRaceLocationSection` and
`EditMedalLocationSection`. Nothing validates or canonicalises the values, so one place
accumulates several spellings and no two records reliably match.

Two constraints shape the redesign, and they pull in opposite directions.

**iOS 26 removed the decomposition the current model mirrors.** The four fields map 1:1 onto
`CLPlacemark.country` / `administrativeArea` / `locality` / `subLocality`. On iOS 26
`CLGeocoder` is deprecated, `CLPlacemark` soft-deprecated, and `MKMapItem.placemark`
deprecated in favour of `MKAddress` / `MKAddressRepresentations` — which return *display
strings*. There is no `locality` equivalent, no `subLocality` equivalent, and `regionName`
yields a localized **country name**, not a code. Filling four structured fields from the
modern API alone is not possible.

**The data is destined for more than one platform.** Web, admin web, and Android clients are
planned against the same Firestore documents. Their geocoders (Google Places, Mapbox) *do*
return structured components including ISO country codes — so iOS 26 is the weakest data
source here, not the strongest. They also produce different display strings for the same
place: `"Taoyuan, Taiwan"` from MapKit versus `"Taoyuan City, Taiwan"` from Google Places.

The app has shipped (tags `1.0.0`, `1.0.1`, `1.1.0`), so live records exist in the old shape.

Location is read-only downstream: six sites call `location.formatted`, and nothing filters,
sorts, or groups by it today.

## Goals / Non-Goals

**Goals:**
- Eliminate free-text spelling drift as the normal path for entering a location.
- Define a location shape that every planned client platform can both write and query
  consistently, independent of any one provider's display strings.
- Keep the six existing display call sites working untouched.
- Read existing 1.x records without a migration job or downtime.
- Contain MapKit's deprecation churn so it cannot reach the stored schema.

**Non-Goals:**
- Map-based pin placement, or a map view of recorded locations. The stored coordinates make
  both possible later; neither is built here.
- Backfilling coordinates onto records created before this change.
- ISO 3166-2 subdivision codes for regions.
- Venue- or street-level precision. Locations are city-level; coordinates carry whatever
  precision the provider returned.
- Any change to how medals inherit a location from a selected race entry.

## Decisions

### D1 — The canonical shape is provider-neutral data, not display strings

```swift
struct GeoLocation: Codable, Hashable, Sendable {
  var countryCode: String   // ISO 3166-1 alpha-2, e.g. "TW"
  var city: String          // "Taoyuan"
  var region: String?       // "Oregon" / "British Columbia"; nil where meaningless
  var latitude: Double?
  var longitude: Double?
}
```

*Alternative rejected — store MapKit's `cityWithContext` string as the canonical value.*
It is both locale-sensitive (rendered for the requesting device) and provider-sensitive. An
admin console would show one city as several, and no `GROUP BY` could repair it. Convenient
for iOS alone; wrong for shared data.

*Alternative rejected — keep the four fields unchanged.* It preserves the exact
decomposition iOS 26 no longer supplies, forcing indefinite reliance on deprecated APIs for a
shape no other platform naturally produces either.

### D2 — Store a country code, not a country name

ISO 3166-1 alpha-2 is emitted by every geocoding provider and rendered locally by every
target platform: `Locale.current.localizedString(forRegionCode:)`, `Intl.DisplayNames`,
`Locale.displayCountry`. One stored value serves every client in every language, and it is a
stable grouping key. A stored country name is a localized display artefact — `"Taiwan"`,
`"台灣"`, `"Taïwan"` — and cannot be all three.

### D3 — Drop `district`; coordinates supersede it

`district` was the field most prone to spelling drift (`復興區` / `Fuxing` / `Fuxing
District`) and the least consistent across providers — Apple's `subLocality`, Google's
`sublocality`, and Mapbox's `neighborhood` routinely disagree on both meaning and presence.
A coordinate is exact, provider-neutral, and has no spelling variants, so replacing the
district string with a coordinate is a net gain in information, not a loss. A race in
Fuxing displays as Taoyuan while its coordinate sits on the actual location; the race name
carries the rest.

### D4 — `formatted` is computed, never stored

`formatted` stays as a computed property, so the six display sites are untouched. Computing
at read time means display rules can change per platform and per locale with no migration,
and no record can hold a stale string. Composition is `city`, then `region` when present,
then the country name derived from `countryCode` in the viewer's locale.

### D5 — Search-list picker, no map

A tappable location row opens a sheet with a search field and a live result list; selecting
a result applies the location and dismisses. Chosen over a draggable-pin map and over a
search-then-confirm-on-map hybrid because nothing downstream reads sub-city precision, and
because it is the only one of the three needing no map view, no location authorization, and
no `NSLocationWhenInUseUsageDescription` — keeping a first-time MapKit adoption small. The
resolved location appears in the row immediately on selection, so the user sees what will be
saved before committing. The hybrid remains a clean additive upgrade later; its search half
is exactly what is built here.

### D6 — One protocol, one MapKit file

```swift
protocol PlaceSearchService: Sendable {
  func suggestions(for query: String) -> AsyncStream<[PlaceSuggestion]>
  func resolve(suggestionID: PlaceSuggestion.ID) async throws -> GeoLocation
}
```

`MapKitPlaceSearchService` is the only file importing MapKit or CoreLocation. MapKit types
never escape it: `MKLocalSearchCompletion` is retained internally and keyed by id, while
`PlaceSuggestion` is a plain `{ id, title, subtitle }` value. `LocationPickerViewModel`
therefore has no MapKit dependency and is testable against a stub.

`MKLocalSearchCompleter` is delegate-based and main-actor bound, so the implementation is a
`@MainActor final class` that bridges delegate callbacks into an `AsyncStream`. The
ViewModel debounces the query (~300 ms) before handing it to the service.

### D7 — iOS fills the structured fields from the soft-deprecated `CLPlacemark`

Since the modern API cannot yield `countryCode`, `city`, or `region`, the adapter reads
`isoCountryCode`, `locality`, and `administrativeArea` from the resolved `MKMapItem`'s
placemark, falling back to a `Locale`-based name→code reverse lookup if `isoCountryCode` is
absent. This is deliberate, contained debt: it is soft-deprecated rather than removed, and it
lives behind D6's seam. When Apple removes it, one Swift file changes and **the Firestore
schema does not move**, so web and Android clients are never disturbed by an Apple
deprecation. Bending the shared schema to Apple's current API would have inverted that.

### D8 — Lenient decode, upgrade on write

A custom `init(from:)` reads the current fields when present; otherwise it maps legacy
`city` → `city`, `province` → `region`, resolves the legacy country name to a code, and
leaves coordinates absent. No batch job, no downtime, no scheduled migration — records
upgrade naturally as they are re-saved. Chosen over a one-time sweep because the sweep writes
every document for a benefit (real coordinates on old records) that is explicitly a non-goal.

### D9 — One shared location section

`EditRaceLocationSection` and `EditMedalLocationSection` are byte-identical apart from their
type names. Both are about to gain the same picker wiring, so they collapse into a single
`EditLocationSection`. This is deduplication of existing identical code that this change must
touch anyway, not speculative abstraction.

### D10 — `region` is a plain string

Every provider returns the region name easily; ISO 3166-2 subdivision codes would be
over-engineering for a display field. *Naming caveat:* MapKit's `regionName` means
**country**, and `MKCoordinateRegion` means a map viewport. Neither is what `region` means
here, which is the province/state level. The adapter is the only place all three meet.

## Risks / Trade-offs

- **`CLPlacemark` is eventually removed, not merely deprecated** → Confined to
  `MapKitPlaceSearchService` by D6. Replacement is one file, and the stored schema and every
  other platform are unaffected. Compiler deprecation warnings are the early signal.
- **Build 1.1.0 cannot read records written after this change** — `country` and `city` are
  required there and `countryCode` is unknown to it → Ship as a version bump. Lenient
  decoding is deliberately one-directional (new build reads old data); backward
  compatibility for the old build is not attempted, as this is a single-user app with a
  controlled install base.
- **`isoCountryCode` or `locality` may be absent for sparse results** (remote trailheads,
  water bodies) → Country code falls back to a `Locale` reverse lookup on the country name;
  an absent city leaves the field empty and the user completes it via the manual fallback,
  which is why the fallback is a requirement rather than a convenience.
- **A legacy country name may not resolve to a code** (misspelled or non-English) → The
  record still decodes, with the remaining fields intact, rather than failing the whole
  document. Covered by an explicit scenario.
- **Search requires the network** → The manual fallback keeps location entry possible
  offline; failures surface as `AppError` through the existing `ErrorWrapper` bridge.
- **`cityWithContext` behaviour for Taiwan is inferred, not observed** → Verified by a
  simulator spike as the first task, before any dependent code is written.
- **Locale drift on legacy `region` values** — `province` was free text, so migrated regions
  inherit whatever was typed → Accepted; regions are display-only, and `countryCode` is the
  field carrying canonical meaning.

## Migration Plan

1. Reshape `GeoLocation` with lenient decoding (D8), test-first against captured legacy JSON.
2. Land the picker and the shared section; existing records continue to display via the
   legacy decode path.
3. Ship as a version bump — see the breaking-read risk above.
4. Records migrate opportunistically as races and medals are edited. No sweep is scheduled;
   never-edited records keep decoding through the legacy path indefinitely, which is a
   supported steady state rather than a temporary one.

**Rollback:** revert the build. Any record already re-saved in the new shape will not decode
on 1.1.0, so rollback is only clean before the new build reaches devices — the same
constraint as the version bump.

## Open Questions

- Does `isoCountryCode` reliably return `TW` for Taiwanese results, and is
  `administrativeArea` empty or meaningless there? Resolved by the task-1 spike; it decides
  whether `region` is simply `nil` for Taiwan or needs suppression logic.
- Should `city` fall back to the place's own name when `locality` is absent (a named
  trailhead with no city), or should the field stay empty for the user to complete? Deferred
  to implementation, once the spike shows how often `locality` is actually missing.
