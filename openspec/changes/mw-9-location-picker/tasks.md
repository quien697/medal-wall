## 1. Spike — confirm what the APIs actually return

- [ ] 1.1 In a simulator, run `MKLocalSearchCompleter` → `MKLocalSearch` for `Fuxing`, `Taoyuan`, `Portland`, and `Vancouver`. Record, for each resolved `MKMapItem`: `placemark.isoCountryCode`, `placemark.locality`, `placemark.administrativeArea`, and `addressRepresentations.cityWithContext`. Confirm Taiwanese results yield `TW` with an empty or meaningless `administrativeArea`.
- [ ] 1.2 Write the findings into `design.md` → Open Questions, resolving both entries (whether `region` is simply `nil` for Taiwan, and how often `locality` is absent). Do not start task 2 until this is answered — the display and fallback behaviour depend on it.

## 2. GeoLocation reshape (TDD — pure, offline, no MapKit)

- [ ] 2.1 Write failing tests for the new shape: encode/decode round-trip of `countryCode`, `city`, `region`, `latitude`, `longitude`. Then reshape the struct.
- [ ] 2.2 Write failing tests decoding a captured **legacy** JSON payload (`country`/`province`/`city`/`district`) — asserting `city` → `city`, `province` → `region`, country name → ISO code, coordinates absent. Then implement the lenient `init(from:)`.
- [ ] 2.3 Write a failing test for a legacy country name that resolves to no code — the record still decodes and the other fields stay intact. Then implement the fallback.
- [ ] 2.4 Write failing tests for coordinate guards: latitude outside −90…90 and longitude outside −180…180 each decode as `nil` while the location stays usable. Then implement the validation.
- [ ] 2.5 Write failing tests for computed `formatted`: `TW` with no region renders city + localized country; a US location renders city + region + country; an absent region leaves no empty separator. Then implement `formatted`.

## 3. PlaceSearchService — the MapKit seam

- [ ] 3.1 Define `PlaceSuggestion` (`id`, `title`, `subtitle` — no MapKit types) and the `PlaceSearchService` protocol (`suggestions(for:)` → `AsyncStream<[PlaceSuggestion]>`, `resolve(suggestionID:)` → `GeoLocation`).
- [ ] 3.2 Implement `MapKitPlaceSearchService` as a `@MainActor final class`: bridge `MKLocalSearchCompleterDelegate` callbacks into an `AsyncStream`, retain completions internally keyed by id, and resolve a selection into `GeoLocation` using the fields confirmed in task 1.1, with a `Locale` name→code reverse lookup when `isoCountryCode` is absent. Throw `AppError` on failure. This is the **only** file importing MapKit or CoreLocation; it is not unit tested (network).

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
