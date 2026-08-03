## 1. Spike — confirm what the APIs actually return

- [x] 1.1 Probed `MKLocalSearch` on the macOS 26.5.2 host — same MapKit backend as iOS, and far quicker than standing up a simulator app — for Fuxing, Taoyuan, Taipei, Portland, and Vancouver. Full table in `design.md` → Spike Findings. `isoCountryCode` reliable (`TW`/`US`/`CA`); `cityWithContext` **empty** for every Taiwanese result; `administrativeArea` and `locality` swap meaning between Taiwan and the US/Canada. *Not covered:* `MKLocalSearchCompleter` itself, which needs a run loop — its suggestion titles get verified when the picker is built in 3.2 and 5.1.
- [x] 1.2 Folded the findings into `design.md` (new Spike Findings section; D1, D3, D4 and D7 amended; both Open Questions resolved; a cross-provider divergence risk added) and corrected `specs/location-entry/spec.md`, whose "Region omitted where it carries no meaning" scenario the spike disproved.

## 2. GeoLocation reshape (TDD — pure, offline, no MapKit)

- [ ] 2.1 Write failing tests for the new shape: encode/decode round-trip of `countryCode`, `city`, `region`, `latitude`, `longitude`. Then reshape the struct.
- [ ] 2.2 Write failing tests decoding a captured **legacy** JSON payload (`country`/`province`/`city`/`district`) — asserting `city` → `city`, `province` → `region`, country name → ISO code, coordinates absent. Then implement the lenient `init(from:)`.
- [ ] 2.3 Write a failing test for a legacy country name that resolves to no code — the record still decodes and the other fields stay intact. Then implement the fallback.
- [ ] 2.4 Write failing tests for coordinate guards: latitude outside −90…90 and longitude outside −180…180 each decode as `nil` while the location stays usable. Then implement the validation.
- [ ] 2.5 Write failing tests for computed `formatted` using the spike's real values — `("Fuxing District", "Taoyuan City", TW)` → `"Fuxing District, Taoyuan City, Taiwan"`; `("", "Taipei City", TW)` → `"Taipei City, Taiwan"` (an absent city must leave no empty separator); `("Portland", "OR", US)` → `"Portland, OR, United States"`; `("Vancouver", "BC", CA)` → `"Vancouver, BC, Canada"`. Then implement `formatted`.

## 3. PlaceSearchService — the MapKit seam

- [ ] 3.1 Define `PlaceSuggestion` (`id`, `title`, `subtitle` — no MapKit types) and the `PlaceSearchService` protocol (`suggestions(for:)` → `AsyncStream<[PlaceSuggestion]>`, `resolve(suggestionID:)` → `GeoLocation`).
- [ ] 3.2 Implement `MapKitPlaceSearchService` as a `@MainActor final class`: bridge `MKLocalSearchCompleterDelegate` callbacks into an `AsyncStream`, retain completions internally keyed by id, and resolve a selection into `GeoLocation` by mapping `isoCountryCode` → `countryCode`, `locality` → `city`, and `administrativeArea` → `region` **verbatim, with no per-country branching** (see design Spike Findings 3–4), with a `Locale` name→code reverse lookup when `isoCountryCode` is absent. Throw `AppError` on failure. This is the **only** file importing MapKit or CoreLocation; it is not unit tested (network).

## 4. LocationPickerViewModel (TDD against a stub)

- [ ] 4.1 Add a `StubPlaceSearchService` test double returning scripted suggestions, empty results, or a thrown error.
- [ ] 4.2 Write failing tests that a query produces mapped suggestions and that rapid successive queries are debounced to a single search. Then implement.
- [ ] 4.3 Write a failing test that a query matching nothing yields an empty-results state and leaves the current location unchanged. Then implement.
- [ ] 4.4 Write a failing test that a search or resolution failure sets `error` as an `AppError` and leaves the current location unchanged. Then implement.
- [ ] 4.5 Write a failing test that selecting a suggestion applies the resolved `GeoLocation` and signals dismissal. Then implement.

## 5. Picker and section views

- [ ] 5.1 Build `LocationPickerView` — search field, live results list, empty-results state, error presentation via the existing `ErrorWrapper` + `ErrorView` bridge. Add a `#Preview` per distinct state (results, empty, error).
- [ ] 5.2 Build the shared `EditLocationSection` — a tappable row showing `formatted` (or a "Choose a location" placeholder) that presents the picker, plus the manual-entry fallback for offline and unknown places. Add a `#Preview`.
- [ ] 5.3 Delete `EditRaceLocationSection.swift` and `EditMedalLocationSection.swift`.

## 6. Wire into the edit flows

- [ ] 6.1 `EditRaceViewModel`: replace the four `String` fields with a single `GeoLocation` draft; update `init` (both `.add` and `.edit`), `isValid` (a location has been chosen, rather than country + city non-empty), and `save()`.
- [ ] 6.2 `EditMedalViewModel`: the same replacement, including the race-entry copy path that currently copies four fields from the selected `Race`.
- [ ] 6.3 Update `EditRaceView` and `EditMedalView` to use `EditLocationSection`.

## 7. Sample data and display

- [ ] 7.1 Update `Race+SampleData` and `Medal+SampleData` to the new shape, keeping the existing Taipei / Vancouver examples and adding coordinates.
- [ ] 7.2 Confirm the six `location.formatted` display sites still compile and render unchanged: `RaceList`, `RaceDetailView`, `RaceDetailHeroSection`, `MedalDetailView`, `MedalDetailHeroSection`, and `RaceEntryPicker/RaceEntryList` (the race-picker row, which displays a race's location during medal creation).

## 8. Verify

- [ ] 8.1 Full test suite green: `xcodebuild test -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`.
- [ ] 8.2 App builds and SwiftLint is clean.
- [ ] 8.3 Simulator check: pick a location for a race and for a medal; confirm the row shows the resolved location before saving, that manual entry still works with the network disabled, and that a record written by 1.1.0 still displays correctly.
- [ ] 8.4 Bump `MARKETING_VERSION` — build 1.1.0 cannot read records written in the new shape, so this must not ship as a silent update.
