## 1. Spike — confirm what the APIs actually return

- [x] 1.1 Probed `MKLocalSearch` on the macOS 26.5.2 host — same MapKit backend as iOS, and far quicker than standing up a simulator app — for Fuxing, Taoyuan, Taipei, Portland, and Vancouver. Full table in `design.md` → Spike Findings. `isoCountryCode` reliable (`TW`/`US`/`CA`); `cityWithContext` **empty** for every Taiwanese result; `administrativeArea` and `locality` swap meaning between Taiwan and the US/Canada. *Not covered:* `MKLocalSearchCompleter` itself, which needs a run loop — its suggestion titles get verified when the picker is built in 3.2 and 5.1.
- [x] 1.2 Folded the findings into `design.md` (new Spike Findings section; D1, D3, D4 and D7 amended; both Open Questions resolved; a cross-provider divergence risk added) and corrected `specs/place-entry/spec.md`, whose "Region omitted where it carries no meaning" scenario the spike disproved.

## 2. Place reshape (TDD — pure, offline, no MapKit)

> **Sequencing note.** Reshaping `Place` breaks every consumer, so the test target
> cannot compile — and therefore cannot run — until tasks 6 and 7 land. All tests below were
> written before the implementation, and the logic was verified standalone (`swiftc` harness,
> 30/30 assertions covering every case in these tasks). Treat 2.1–2.5 as implemented and
> logic-verified, but **not yet verified in-target**; task 8.1 is the real gate.

- [x] 2.1 Write failing tests for the new shape: encode/decode round-trip of `countryCode`, `city`, `region`. Then reshape the struct.
- [x] 2.2 Write failing tests decoding a captured **legacy** JSON payload (`country`/`province`/`city`/`district`) — asserting `city` → `city`, `province` → `region`, country name → ISO code, coordinates absent. Then implement the lenient `init(from:)`.
- [x] 2.3 Write a failing test for a legacy country name that resolves to no code — the record still decodes and the other fields stay intact. Then implement the fallback.
- [x] 2.4 **Superseded — coordinates were cut (design D11).** Replaced by: write a failing parameterized test that a legacy country resolves from short forms (`USA`, `UK`, `Korea`), ISO codes, and Chinese/Japanese names, then harden `regionCodesByName` to index codes, four locales, and an alias table. Plain English matching would have silently dropped the country from any record saying `"USA"` or `"台灣"` — and the project's own fixtures used `"USA"`.
- [x] 2.5 Write failing tests for computed `formatted` using the spike's real values — `("Fuxing District", "Taoyuan City", TW)` → `"Fuxing District, Taoyuan City, Taiwan"`; `("", "Taipei City", TW)` → `"Taipei City, Taiwan"` (an absent city must leave no empty separator); `("Portland", "OR", US)` → `"Portland, OR, United States"`; `("Vancouver", "BC", CA)` → `"Vancouver, BC, Canada"`. Then implement `formatted`.

## 3. PlaceSearchService — the MapKit seam

- [x] 3.1 Define `PlaceSuggestion` (`id`, `title`, `subtitle` — no MapKit types) and the `@MainActor PlaceSearchService` protocol. **Changed from the plan:** `suggestions(for:)` returns `AsyncThrowingStream<[PlaceSuggestion], any Error>`, not `AsyncStream` — the spec requires a failed search to surface as an error, which a non-throwing stream cannot express. A query that merely matches nothing still yields `[]`, keeping "no results" and "search broke" distinguishable.
- [x] 3.2 Implement `MapKitPlaceSearchService` as a `@MainActor final class`: bridge `MKLocalSearchCompleterDelegate` callbacks into an `AsyncStream`, retain completions internally keyed by id, and resolve a selection into `Place` by mapping `isoCountryCode` → `countryCode`, `locality` → `city`, and `administrativeArea` → `region` **verbatim, with no per-country branching** (see design Spike Findings 3–4), with a `Locale` name→code reverse lookup when `isoCountryCode` is absent. Throw `AppError` on failure. This is the **only** file importing MapKit or CoreLocation; it is not unit tested (network).

- [x] 3.3 *(not in the original plan)* Add `AppError.placeSearchFailed(String)` and `AppError.placeNotResolved`, for the two failure modes. *(Their guidance text was later revised in 7c.3: it pointed at manual entry, which no longer exists.)* Verified containment: exactly one file imports MapKit/CoreLocation and exactly one references any `MK*`/`CL*` type. The build emits a single deprecation warning, on the `placemark` access in that file — the intended early-warning signal from design D7.

## 4. PlacePickerViewModel (TDD against a stub)

- [x] 4.1 Add a `StubPlaceSearchService` test double returning scripted suggestions, empty results, or a thrown error.
- [x] 4.2 Write failing tests that a query produces mapped suggestions and that rapid successive queries are debounced to a single search. Then implement.
- [x] 4.3 Write a failing test that a query matching nothing yields an empty-results state and leaves the current location unchanged. Then implement.
- [x] 4.4 Write a failing test that a search or resolution failure sets `error` as an `AppError` and leaves the current location unchanged. Then implement.
- [x] 4.5 Write a failing test that selecting a suggestion applies the resolved `Place` and signals dismissal. Then implement.

- [x] 4.6 *(not in the original plan)* Add the four new source files to the `MedalWallTests` membership exceptions in `project.pbxproj`. The project compiles a curated list of app sources *into* the test target, so a type absent from that list exists only in the app module — which made `PlacePickerViewModel` return `MedalWall.Place` while the tests built `MedalWallTests.Place`, and made the stub's `async` requirement mismatch across Swift 5/6 isolation defaults. Any future type referenced from tests must be added to that list.

## 5. Picker and section views

- [x] 5.1 Build `PlacePickerView` — search field, live results list, empty-results state, error presentation via the existing `ErrorWrapper` + `ErrorView` bridge. Add a `#Preview` per distinct state (results, empty, error).
- [x] 5.2 Build the shared `EditPlaceSection` — a tappable row showing `formatted` (or a "Choose a location" prompt) that presents `PlacePickerView` as a sheet and applies the chosen location, with `#Preview`s for the filled and empty states. *(An earlier revision also carried city/region text fields and a country picker for manual entry; those were removed in 7c.3.)*
- [x] 5.3 Delete `EditRaceLocationSection.swift` and `EditMedalLocationSection.swift`.

- [x] 5.4 *(not in the original plan)* Fix SwiftLint violations introduced across this change: 24 blank lines after `// MARK:` in six files, one `trailing_comma`, one `empty_string`. Earlier "SwiftLint clean" claims in this change were wrong — the grep used to check put `.swift` after `warning:`, but SwiftLint prints the path first, so it matched nothing. Correct pattern: `grep -E "\.swift:[0-9]+:[0-9]+: warning:"`.

## 6. Wire into the edit flows

- [x] 6.1 `EditRaceViewModel`: replace the four `String` fields with a single `Place` draft; update `init` (both `.add` and `.edit`), `isValid` (a location has been chosen, rather than country + city non-empty), and `save()`.
- [x] 6.2 `EditMedalViewModel`: the same replacement, including the race-entry copy path that currently copies four fields from the selected `Race`.
- [x] 6.3 Update `EditRaceView` and `EditMedalView` to use `EditPlaceSection`.
- [x] 6.4 *(not in the original plan)* Update the ViewModel and model test files that referenced the old four-field shape: `EditRaceViewModelTests`, `EditMedalViewModelTests`, `MedalDetailViewModelTests`, `RaceDetailViewModelTests`, `RacesViewModelTests`, `MedalComputedTests`, `MedalStatsTests`, `RaceComputedTests`.

## 7. Sample data and display

- [x] 7.1 Update `Race+SampleData` and `Medal+SampleData` to the new shape, keeping the existing Taipei / Vancouver examples.
- [x] 7.2 Confirm the six `location.formatted` display sites still compile and render unchanged: `RaceList`, `RaceDetailView`, `RaceDetailHeroSection`, `MedalDetailView`, `MedalDetailHeroSection`, and `RaceEntryPicker/RaceEntryList` (the race-picker row, which displays a race's location during medal creation).

## 7b. Trim to area level (scope change, 2026-08-06)

- [x] 7b.1 Cut `latitude`/`longitude` from `Place`, its `CodingKeys`, the decoder, and the coordinate guard. Locations are area-level; a race's exact start line lives on its official site and nothing in the app read a coordinate. Prompted by 田中馬拉松 — the "田中" marathon actually held in 彰化縣 — which showed `city` + `region` already carry both the familiar name and the containing county.
- [x] 7b.2 Remove coordinate extraction and `import CoreLocation` from `MapKitPlaceSearchService`; strip coordinates from `Race+SampleData` and the picker test fixture.
- [x] 7b.3 Harden the country-name lookup (see 2.4) and cover it with a parameterized test.
- [x] 7b.4 Update `proposal.md`, `design.md` (D1, D2, D3 rewritten; **D11 added** recording the cut and its accepted cost), and the place-entry spec delta — the `Coordinate Validation` requirement is **removed**, and two scenarios added: 田中馬拉松 area-level identification, and country-name resolution beyond English.

## 7c. Search-only, city-level (scope change, 2026-08-06)

- [x] 7c.1 Normalize resolved places to **city level** (design D12). Extracted as a pure `MapKitPlaceSearchService.location(isoCountryCode:countryName:administrativeArea:subAdministrativeArea:locality:)` over strings so the rule is unit-testable without a network. Promotes `administrativeArea` to `city` when `subAdministrativeArea == administrativeArea` or `locality` is absent; drops a region that repeats the city or the country code. Reverses the spike's rejection of this heuristic — the verbatim mapping it protected produced districts where the app wants cities.
- [x] 7c.2 Add `PlaceNormalizationTests` — 10 tests pinned to values observed from MapKit (復興區→桃園市, 田中鎮→彰化縣, Taipei, Portland/OR, Vancouver/BC, Shinjuku/Tokyo, bare Tokyo, Singapore, region-equals-city, country-name fallback).
- [x] 7c.3 Make search the only way to set a location (design D13). `EditPlaceSection` reduced to a single Place row; deleted `CountryOption.swift`, the city/region text fields, the country picker, and `Place.regionText`, which lost its only consumer.
- [x] 7c.4 Update the spec delta: **`Manual Location Fallback` requirement removed**, `Place Search and Selection` now forbids hand-typed locations, and a new **`City-Level Normalization`** requirement added with three scenarios.

## 7d. Rename to the Place vocabulary (scope change, 2026-08-06)

- [x] 7d.1 `GeoLocation` → **`Place`**. The old name promised coordinates that no longer exist; the new one completes the vocabulary already in the codebase, where `PlaceSearchService` returns a `PlaceSuggestion` that resolves into a `Place`. Verified `Place` is unclaimed by Foundation, SwiftUI, MapKit, CoreLocation, Contacts, AppIntents, SwiftData, CoreData, and PhotosUI.
- [x] 7d.2 Rename the surrounding code to match: `LocationPickerView` → `PlacePickerView`, `LocationPickerViewModel` → `PlacePickerViewModel`, `EditLocationSection` → `EditPlaceSection`, `Features/LocationPicker/` → `PlacePicker/` (later moved to `Shared/Components/PlacePicker/`), `GeoLocationTests` → `PlaceTests`, plus `selectedLocation` → `selectedPlace` and the service's `location(...)` → `place(...)`. Update the `project.pbxproj` membership paths.
- [x] 7d.3 At this point the `location` property, the user-facing word "Location", and the `location-entry` capability were all left alone, on the reasoning that renaming the property would be a second wire-format break. **Superseded by 7f**: once the compatibility path was dropped (7e) the three existing records had to be hand-edited anyway, so renaming the stored key cost nothing extra.

## 7e. Drop the compatibility path (scope change, 2026-08-06)

- [x] 7e.1 Delete `LegacyCodingKeys`, the custom `init(from:)`, `regionCode(forCountryName:)`, `regionCodesByName`, `countryNameAliases`, and `nonEmpty`. `Place` now has a fully synthesized `Codable` and drops from 137 lines to 47. Supersedes tasks 2.2, 2.3, and 2.4.
- [x] 7e.2 Simplify `MapKitPlaceSearchService.place(...)`: the `countryName` parameter and the name-to-code fallback are gone, leaving `countryCode = isoCountryCode ?? ""`. A place with no country code fails `isValid` and cannot be saved, which is the right outcome.
- [x] 7e.3 Rewrite `PlaceTests` around the current shape only — 15 `@Test` declarations (29 cases) down to 7. Drop `testCountryNameFallback` from `PlaceNormalizationTests`. Suite total 263 → 240.
- [x] 7e.4 Update the spec delta (**`Reading Previously Stored Locations` requirement removed**), `design.md` (D2 trimmed, **D8 rewritten** to record that there is no compatibility path and why that is safe only at three records), the Migration Plan, and the proposal's breaking-change impact.

## 7f. Complete the Place vocabulary (scope change, 2026-08-06)

- [x] 7f.1 Rename the stored property `location` → `place` on `Race` and `Medal`, changing the Firestore key with it. Free at this point: 7e removed the compatibility path, so the three existing records are being hand-edited regardless. Every call site, ViewModel, view, sample record, and test follows.
- [x] 7f.2 Rename `Place.isComplete` → **`isValid`**. "Complete" implied all three fields were required, but `region` is optional; `isValid` also matches the `isFormValid` already on both edit ViewModels.
- [x] 7f.3 Rename the capability `location-entry` → **`place-entry`** and rewrite the spec delta in place vocabulary. Also fixed a contradiction introduced in 7b: the 田中馬拉松 scenario still claimed the system "records both the locality and the administrative area", which the City-Level Normalization requirement added in 7c had already made false — 田中鎮 is discarded, 彰化縣 is recorded.
- [x] 7f.4 Correct the migration plan and breaking-change impact: the stored key is `place`, not `location`, so the three records need the field renamed as well as reshaped.

## 8. Verify

- [x] 8.1 Full test suite green: **240 tests passed, 0 failures** (`xcodebuild test`, iPhone 17 Pro simulator). Matches the 240 expected after 7e.3 trimmed the suite from 263.
- [x] 8.2 Clean build succeeds and SwiftLint is clean. The clean build emits **exactly one** project warning — `MapKitPlaceSearchService.swift:95` `'placemark' was deprecated in iOS 26.0` — which is the intended early-warning signal from design D7, not a defect. An incremental build was checked first and reported nothing; it recompiled no sources, so only the clean build actually verifies this.
- [x] 8.3 Verified by the author on a physical iPhone 15 Pro after hand-updating the three Firestore records from `location` to `place`. Migration Plan step 1 is therefore complete.
- [x] 8.4 `MARKETING_VERSION` bumped `1.1.0` → **`1.2.0`** on the app target (Debug and Release). The test target's unrelated `1.0` is left alone.

- [x] 8.5 *(not in the original plan)* Corrected three passages in `design.md` that later scope changes had left stale, found while assessing the spec sync at archive time: D3 still claimed 田中馬拉松 stores `city: 田中鎮, region: 彰化縣`, which D12's city-level normalization had already made false; D7 still described the `Locale` name→code fallback deleted in 7e and claimed the mapping was verbatim; and two Risks bullets still offered the manual fallback removed in 7c/D13 as the mitigation for sparse results and for offline entry.
- [x] 8.6 *(not in the original plan)* Added the missing `specs/medals/spec.md` delta. Tasks 6.2 and 7f.1 renamed `Medal.location` → `place`, and `races` received a delta for the identical rename, but `medals` never did — so `openspec/specs/medals/spec.md` would have kept the old four-field wording forever once this change archived.
