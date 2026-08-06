## Context

`Place` today is four free-text strings — `country`, `province`, `city`, `district` —
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

A place is read-only downstream: six sites render `place.formatted`, and nothing filters,
sorts, or groups by it today.

## Spike Findings

Measured on macOS 26.5.2 / Swift 6.3.3 via `MKLocalSearch`, which shares MapKit's backend
with iOS. Task 1.1.

| Query | `isoCountryCode` | `administrativeArea` | `subAdministrativeArea` | `locality` | `cityWithContext` |
| --- | --- | --- | --- | --- | --- |
| Fuxing District, Taoyuan | `TW` | Taoyuan City | Taoyuan City | **Fuxing District** | **`""`** |
| Taipei | `TW` | Taipei City | Taipei City | `nil` | **`""`** |
| Portland, Oregon | `US` | OR | Multnomah County | Portland | `Portland, OR, United States` |
| Vancouver, British Columbia | `CA` | BC | Metro Vancouver | Vancouver | `Vancouver BC, Canada` |

1. **`isoCountryCode` is dependable** across all three target markets. D2 and D7 hold.
2. **`cityWithContext` is an empty string for every Taiwanese result** — empty, not `nil`.
   See D4; this is why `formatted` must be composed rather than taken ready-made.
3. **`administrativeArea` and `locality` swap meaning by country.** In the US and Canada
   `administrativeArea` is the state/province and `locality` the city. In Taiwan
   `administrativeArea` is the *city* and `locality` the *district*. Google Places divides
   the same place differently again, so these two fields cannot be canonical on any platform
   — hence the display-only status recorded in D1.
4. A per-country normalisation was **considered and rejected**: `subAdministrativeArea ==
   administrativeArea` does discriminate Taiwan (`Taoyuan City` == `Taoyuan City`) from the
   US (`Multnomah County` ≠ `OR`) and Canada (`Metro Vancouver` ≠ `BC`), and would yield the
   tidier "Taoyuan, Taiwan". It was rejected as an undocumented coincidence layered on an
   already-deprecated API — it could break silently, and it still would not make iOS and
   Android agree on a value.
5. `locality` is genuinely absent for some city-level results (Taipei). No fallback is
   needed: `formatted` skips empty components, so `["", "Taipei City", "Taiwan"]` renders
   "Taipei City, Taiwan" correctly.

## Goals / Non-Goals

**Goals:**
- Eliminate free-text spelling drift entirely: search is the only way to set a location.
- Define a location shape that every planned client platform can both write and query
  consistently, independent of any one provider's display strings.
- Keep the six existing display call sites working untouched.
- Read existing 1.x records without a migration job or downtime.
- Contain MapKit's deprecation churn so it cannot reach the stored schema.

**Non-Goals:**
- Map-based pin placement, or a map view of recorded locations.
- Storing coordinates at all. Locations are recorded at **area level**; a race's exact start
  line lives on its official site, and nothing in the app reads or displays a position.
- ISO 3166-2 subdivision codes for regions.
- Venue- or street-level precision.
- Any change to how medals inherit a location from a selected race entry.

## Decisions

### D1 — The canonical shape is provider-neutral data, not display strings

```swift
struct Place: Codable, Hashable, Sendable {
  var countryCode: String   // ISO 3166-1 alpha-2, e.g. "TW" — canonical
  var city: String          // provider's `locality` — display only
  var region: String?       // provider's `administrativeArea` — display only
}
```

**Only `countryCode` is canonical.** The task-1 spike (see Spike
Findings) showed that `city` and `region` carry provider-dependent *meaning*, not just
provider-dependent spelling: Apple returns Taiwan's city in `administrativeArea` and its
district in `locality`, the reverse of its US and Canadian behaviour, and Google Places
splits the same place differently again. `city` and `region` are therefore display fields.
Nothing may group, filter, or join on them — that is what `countryCode` is for. With
coordinates cut (D11), `countryCode` is the single value in the schema meaning the same thing
across languages, devices, and client platforms — which is why the lookup producing it is
hardened rather than best-effort (D2).

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
`"台灣"`, `"Taïwan"` — and cannot be all three. Storing the name would also mean localizing at
*write* time: the same place resolved on a Chinese device would record `"台灣"` and on an
English one `"Taiwan"`, so two records for one country would stop matching.

### D3 — Drop `district`; `locality` already carries it

`district` was the field most prone to spelling drift (`復興區` / `Fuxing` / `Fuxing
District`) and the least consistent across providers — Apple's `subLocality`, Google's
`sublocality`, and Mapbox's `neighborhood` routinely disagree on both meaning and presence.

Removing the dedicated field loses nothing, because the spike showed a provider's `locality`
already returns that level. 田中馬拉松 is the clearest case: everyone calls it the "田中"
marathon, but it is held in 彰化縣. It stores as `city: "田中鎮"`, `region: "彰化縣"` — so both
the name people use and the county it sits in survive, in two fields rather than three.

An earlier draft justified this differently, arguing that a stored coordinate would supersede
the district string. The spike disproved the premise: nothing was lost that needed
superseding, which is part of why coordinates were later cut (D11).

### D4 — `formatted` is computed, never stored

`formatted` stays as a computed property, so no display site needed rendering logic of its
own; the six were touched only by the later `location` → `place` property rename. Computing
at read time means display rules can change per platform and per locale with no migration,
and no record can hold a stale string. Composition is `city`, then `region` when present,
then the country name derived from `countryCode` in the viewer's locale.

The spike turned this from a preference into a requirement: `MKAddressRepresentations`
`cityWithContext` returns an **empty string** for every Taiwanese result. Had display been
built on MapKit's ready-made string — the approach considered and rejected in D1 — every
location in the app's primary market would have rendered blank.

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
@MainActor
protocol PlaceSearchService {
  func suggestions(for query: String) -> AsyncThrowingStream<[PlaceSuggestion], any Error>
  func resolve(suggestionID: PlaceSuggestion.ID) async throws -> Place
}
```

`MapKitPlaceSearchService` is the only file importing MapKit or CoreLocation. MapKit types
never escape it: `MKLocalSearchCompletion` is retained internally and keyed by id, while
`PlaceSuggestion` is a plain `{ id, title, subtitle }` value. `PlacePickerViewModel`
therefore has no MapKit dependency and is testable against a stub.

`MKLocalSearchCompleter` is delegate-based and main-actor bound, so the implementation is a
`@MainActor final class` that bridges delegate callbacks into an `AsyncThrowingStream` — a
non-throwing stream could not distinguish "nothing matched" from "the search failed". The
ViewModel debounces the query (~300 ms) before handing it to the service.

### D7 — iOS fills the structured fields from the soft-deprecated `CLPlacemark`

Since the modern API cannot yield `countryCode`, `city`, or `region`, the adapter reads
`isoCountryCode`, `locality`, and `administrativeArea` from the resolved `MKMapItem`'s
placemark, falling back to a `Locale`-based name→code reverse lookup if `isoCountryCode` is
absent. The spike confirmed `isoCountryCode` is dependable — `TW`, `US`, and `CA` all
correct — so the fallback is genuinely an edge case rather than the common path. The mapping
is applied verbatim, with no per-country branching (see Spike Findings). This is deliberate, contained debt: it is soft-deprecated rather than removed, and it
lives behind D6's seam. When Apple removes it, one Swift file changes and **the Firestore
schema does not move**, so web and Android clients are never disturbed by an Apple
deprecation. Bending the shared schema to Apple's current API would have inverted that.

### D8 — No migration path; existing records are replaced by hand

`Place` decodes only the current shape. There is no reader for the four-field shape written
by 1.0.0–1.1.0, so those records do not load at all.

That is safe here only because of scale: three records exist, and they are updated directly.
Carrying a compatibility path for three rows would have meant `LegacyCodingKeys`, a custom
`init(from:)`, a country-name-to-ISO lookup spanning four locales, and an alias table for
`USA` / `UK` / `台灣` — roughly 50 lines and 10 tests, permanently, to read data that can be
retyped in minutes.

The failure mode was checked before choosing this, and it is unforgiving:
`RaceFirestoreRepository.fetchRaces()` is `try snapshot.documents.map { try $0.data(as:) }`,
so **one** stale record fails the whole fetch — the entire race or medal list, not one row —
and the app cannot then display those records for editing. Recovery is only possible outside
the app. With three known records that is a non-issue; at any larger scale the compatibility
path would have been the correct trade.

### D9 — One shared place section

`EditRaceLocationSection` and `EditMedalLocationSection` are byte-identical apart from their
type names. Both are about to gain the same picker wiring, so they collapse into a single
`EditPlaceSection`. This is deduplication of existing identical code that this change must
touch anyway, not speculative abstraction.

### D10 — `region` is a plain string

Every provider returns the region name easily; ISO 3166-2 subdivision codes would be
over-engineering for a display field. *Naming caveat:* MapKit's `regionName` means
**country**, and `MKCoordinateRegion` means a map viewport. Neither is what `region` means
here, which is the province/state level. The adapter is the only place all three meet.

### D11 — No coordinates

An earlier draft stored `latitude`/`longitude`. They are cut.

The original justification — that a coordinate would supersede the dropped `district` string
— did not survive the spike, which showed `locality` already carries district-level names
(D3). What remained was a field nothing read, no view displayed, and that every planned
client platform would nonetheless be obliged to populate correctly. Locations in this app are
*areas*, not positions: 田中馬拉松 is "the 田中 marathon in 彰化", and its exact start line is
published on the race's own site.

A second argument for keeping them — that backfilling later would be expensive — was also
overstated. Approximate coordinates can be re-geocoded from the stored `city` / `region` /
`countryCode` at any time, and a city centroid is all a country-zoom map would render.

*Cost, accepted:* coordinates were the only provider-neutral way to tell that two records
describe the same place. Cross-platform deduplication below country level is therefore not
possible — see Risks.

### D12 — City-level normalization

`locality` and `administrativeArea` do not mean the same thing in every country. The US and
Canada put the city in `locality`; Taiwan puts the city or county in `administrativeArea`
(桃園市, 彰化縣) and a district or township below it in `locality` (復興區, 田中鎮). Mapping
`locality → city` verbatim therefore records a district for Taiwan, which is finer than this
app wants and inconsistent with every other country.

`subAdministrativeArea == administrativeArea` is the observed signal for the inversion: true
throughout Taiwan, false in the US, Canada, and Japan. When it holds — or when `locality` is
absent entirely — the administrative area is promoted to `city` and no region is recorded.

This heuristic was **considered and rejected during the task-1 spike**, on the grounds that it
leans on an undocumented coincidence in a deprecated API. That judgement was wrong: the
verbatim mapping it protected produces results the app does not want, and a principled rule
that yields wrong answers is worse than a pragmatic one that yields right ones. The rule is
mitigated instead — extracted as a pure function over strings and pinned by unit tests to
values observed from MapKit, so a change in provider behaviour fails a test rather than
silently degrading. Should it ever stop holding, the fallback is the old verbatim mapping,
not a crash.

Handling `locality == nil` through the same branch is what makes a bare "Tokyo" or "Taipei"
resolvable; without it those yield an empty city and fail `isValid`, blocking the save.

### D13 — Search is the only way to set a location

The manual city/region fields and the country picker are removed, and with them the Manual
Location Fallback requirement.

A hand-typed city reintroduces exactly the drift this change exists to eliminate — `Taoyuan`
/ `桃園` / `Taoyuan City` — through a side door, and unlike a rejected search result, a typed
value is *written* and persists. The asymmetry decides it: search-only writes nothing that
later needs reconciling, so starting strict and loosening later is cheap, while starting
loose and tightening leaves drifted rows behind.

*Alternative rejected — a country picker cascading into a subdivision picker.* Foundation
exposes no subdivision data at all (`Locale.Region("TW").subRegions` is empty; `isoRegions`
lists 292 countries and no ISO 3166-2 identifiers), so it would require a bundled dataset to
own and maintain. It would cover Taiwan fully, since Taiwan's 22 subdivisions are the city
level, but the US and Canada would still need the city typed — so drift would be reduced, not
removed. The dataset would also be unusable by the planned web and Android clients, each
needing its own copy.

*Accepted cost:* a location cannot be set without a network. Firestore's offline persistence
would otherwise have queued the write, so this genuinely removes a capability. It is
reversible if the case turns out to be real.

## Risks / Trade-offs

- **`CLPlacemark` is eventually removed, not merely deprecated** → Confined to
  `MapKitPlaceSearchService` by D6. Replacement is one file, and the stored schema and every
  other platform are unaffected. Compiler deprecation warnings are the early signal.
- **Build 1.1.0 cannot read records written after this change** — `country` and `city` are
  required there and `countryCode` is unknown to it → Ship as a version bump. Neither
  direction is readable: the new build cannot read old records either (D8), so the three
  existing records are updated by hand as part of shipping.
- **`isoCountryCode` or `locality` may be absent for sparse results** (remote trailheads,
  water bodies) → Country code falls back to a `Locale` reverse lookup on the country name;
  an absent city leaves the field empty and the user completes it via the manual fallback,
  which is why the fallback is a requirement rather than a convenience.
- **A legacy country name may not resolve to a code** (misspelled or non-English) → The
  record still decodes, with the remaining fields intact, rather than failing the whole
  document. Covered by an explicit scenario.
- **Search requires the network** → The manual fallback keeps location entry possible
  offline; failures surface as `AppError` through the existing `ErrorWrapper` bridge.
- ~~**`cityWithContext` behaviour for Taiwan is inferred, not observed**~~ → **Resolved by
  the task-1 spike.** It returns an empty string for Taiwan, which is why display is composed
  from structured fields rather than taken from MapKit. See D4.
- **`city` and `region` will diverge between platforms for the same place** — Apple and
  Google split administrative levels differently, so an iOS-created record and an
  Android-created one may disagree on which value is the "city" → Accepted and documented in
  D1: these are display fields. Grouping, filtering, and joins use `countryCode`, the only
  provider-neutral value. **Accepted limitation:** with coordinates cut (D11), nothing can
  prove that an iOS record saying `city: "田中鎮"` and an Android record saying
  `city: "彰化市"` describe the same race. Country-level aggregation stays sound; anything
  finer would need a deduplication key this schema deliberately does not carry.
- **Locale drift on legacy `region` values** — `province` was free text, so migrated regions
  inherit whatever was typed → Accepted; regions are display-only, and `countryCode` is the
  field carrying canonical meaning.

## Migration Plan

1. Update the three existing records: rename each document's `location` map to `place`, and
   replace its contents — `{country, province, city, district}` becomes
   `{countryCode, city, region?}`, where `countryCode` is ISO 3166-1 alpha-2 (`TW`, `CA`, `US`)
   and `region` is omitted where it carries no meaning. Do this by hand in the Firestore
   console, or by deleting and re-creating the records in the app.
2. Install the new build.

Order matters: the new build cannot read the old shape, and 1.1.0 cannot read the new one, so
the two steps should happen together.

**Rollback:** revert the build and restore the three records to the old shape. There is no
automatic path in either direction, which is the accepted cost of D8.

## Open Questions

Both questions raised at proposal time were answered by the task-1 spike:

- ~~Does `isoCountryCode` reliably return `TW`, and is `administrativeArea` meaningless
  there?~~ **Answered.** `isoCountryCode` is reliable. `administrativeArea` is *not*
  meaningless for Taiwan — it holds the city — so `region` is populated rather than `nil`,
  and no suppression logic is needed.
- ~~Should `city` fall back to something when `locality` is absent?~~ **Answered: no.**
  `locality` is absent for some city-level results, but `formatted` skips empty components,
  so the rendering is already correct without a fallback.

Nothing is outstanding. Implementation may proceed from task 2.
