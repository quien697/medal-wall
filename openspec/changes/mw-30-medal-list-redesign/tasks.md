## 1. Value Types

- [x] 1.1 Write failing tests for `MedalDistanceFilter`: `.all` and `.category(_)` are
      `Hashable` and carry distinct `id`s, and two `.category` cases built from the same
      distance value are equal (`.custom(42.195)` must equal `.full` — design.md
      Decision 4)
- [x] 1.2 Implement `MedalDistanceFilter` (`Features/Medal/Models/`) — `.all` /
      `.category(RaceDistanceCategory)`, `Hashable`, `Identifiable`, normalizing the
      category through `RaceDistanceCategory(value:)` so equality follows distance rather
      than case
- [x] 1.3 Write failing tests for `MedalYearGroup`: `id` is the year, and two groups with
      the same year are equal
- [x] 1.4 Implement `MedalYearGroup` (`Features/Medal/Models/`) — `Identifiable` with
      `var id: Int { year }`, holding `year` and `medals`

## 2. Ordering & Year Grouping

- [x] 2.1 Write failing tests for `sortedForDisplay`: most recent date first, and two
      medals sharing a date order by `id` so the result is stable regardless of input
      order (spec: Deterministic Collection Ordering)
- [x] 2.2 Write failing tests for `groupedByYear`: years descending, medals within a group
      date-descending, gap years produce no group, an empty array produces no groups, and
      a single medal produces one group of one
- [x] 2.3 Implement `sortedForDisplay` and `groupedByYear` in `Medal+Stats.swift` as
      `Array where Element == Medal` extensions, grouping on the calendar year of
      `medal.date`

## 3. Distance Filter Derivation

- [x] 3.1 Write failing tests for `distanceCategoriesOwned`: only categories present in
      the array are returned, ordered by distance longest first, with no duplicates when
      several medals share a category
- [x] 3.2 Write failing tests covering a custom distance appearing as its own category,
      placed among the presets by its distance value
- [x] 3.3 Write failing tests for `count(for:)`: `.all` returns the full count, a
      `.category` returns only that category's count, and a category absent from the
      collection returns zero
- [x] 3.4 Write failing tests for `filtered(by:)`: `.all` returns everything,
      `.category` returns only matching medals, and every derived option selects at least
      one medal (spec: A Filter Selection Always Has Results)
- [x] 3.5 Implement `distanceCategoriesOwned`, `count(for:)` and `filtered(by:)` in
      `Medal+Stats.swift`, sorting by `category.value` descending — do not make
      `RaceDistanceCategory` `Comparable` for one sort (design.md Decision 5)

## 4. Personal Record Derivation

- [x] 4.1 Write failing tests for `personalRecords`: the fastest time in a category wins,
      each category holds its own record independently, and a category whose medals are
      all untimed produces no entry
- [x] 4.2 Write failing tests for eligibility guards per the project's guard convention: a
      `nil` finish time is excluded, and a stored finish time of `0` or negative is
      excluded rather than winning as the minimum (design.md Decision 3)
- [x] 4.3 Write failing tests for tie-breaking: two medals sharing the fastest time in a
      category mark only the earlier-dated one, so exactly one medal per category is ever
      marked
- [x] 4.4 Write failing tests for `personalRecordIDs`: it contains exactly the ids of
      `personalRecords.values`, and is empty for an empty or fully untimed collection
- [x] 4.5 Write a failing test that records are computed over the whole collection, not a
      filtered subset — filtering to one category marks the same medal as `.all` does
      (spec: Filtering does not move a record)
- [x] 4.6 Implement `personalRecords` and `personalRecordIDs` in `Medal+Stats.swift`,
      deriving the id set from the dictionary so the rule is defined once (design.md
      Decision 2)

## 5. ViewModel

- [x] 5.1 Create `MedalWallTests/Unit/Medal/ViewModels/MedalsViewModelTests.swift` — none
      exists today — and write failing tests that `selectedFilter` defaults to `.all` and
      that setting it narrows the presented groups and their counts
- [x] 5.2 Write failing tests for stale-selection fallback: a `selectedFilter` naming a
      category no longer present resolves to `.all` on read, while a still-present
      selection is kept (spec: Filter Selection Survives a Changed Collection)
- [x] 5.3 Add `selectedFilter` state to `MedalsViewModel` plus computed properties
      delegating to the `Medal+Stats` extensions — `availableFilters`, `yearGroups`,
      `personalRecordIDs`, and `count(for:)`. Resolve the stale selection in the getter,
      not on reload (design.md Decision 6)
- [x] 5.4 Follow the project's ViewModel `// MARK:` order — `Data` → `State` →
      `Dependencies` → `Init` → `Computed` → `Functions`

## 6. Row & Year Section

- [x] 6.1 Build `MedalRow` (`Features/Medal/Medals/Views/`) — 96pt `PhotoImage(as: .medal)`
      with an unconditional `.medalRing()`, beside date / race name / distance / finish
      time. Take `isPersonalRecord: Bool` rather than computing anything in the view
- [x] 6.2 Render the finish time with `Font.TypeScale.Numeric.small` and show
      `No time recorded` in `microLabel` when `finishTime` is nil — not the current `-`
      placeholder (spec: Medals Without a Finish Time)
- [x] 6.3 Show the `PR` marker beside the finish time via `.tagStyle(.record)` when
      `isPersonalRecord` is true
- [x] 6.4 Apply the resolved type scale per design.md Decision 8 — `microLabel` with
      `.tracking()` and `.textCase(.uppercase)` at the call site for row metadata,
      `headline` for the race name. Do not reproduce the mockup's off-scale 9px
- [x] 6.5 Build `MedalYearHeader` — year, spacer, medal count, with the rule beneath
- [x] 6.6 Build `MedalYearSection` composing `MedalYearHeader` with its `MedalRow`s,
      preserving the `NavigationLink` to `MedalDetailView` and the
      `matchedTransitionSource` / `.navigationTransition(.zoom(...))` pair that
      `MedalGridSection` has today
- [x] 6.7 Add a `#Preview` to each new view file per project convention, with named
      previews for the distinct row states (timed, untimed, personal record)

## 7. Filter Bar & List

- [x] 7.1 Build `MedalDistanceFilterBar` — a horizontally scrolling strip of chips, each
      showing its label and count, `.chipStyle(.primary)` when selected and
      `.chipStyle(.secondary)` when not (design.md Decision 8 — not the mockup's
      `#EAE7DF`)
- [x] 7.2 Give the chips a 34pt height inside a 44pt row per §04, so the strip stays
      visually light while the row carries the tap target
- [x] 7.3 Build `MedalList` replacing `MedalGrid` — `MedalEmptyView` when the collection
      is empty, otherwise the filter bar above a `LazyVStack` of `MedalYearSection`s
- [x] 7.4 Add `#Preview`s for `MedalList` covering the empty collection, a single-year
      collection, and a multi-year collection with an active filter

## 8. Screen Wiring & Removals

- [x] 8.1 Point `MedalsView` at `MedalList`, passing the view model through, and change the
      navigation title and `ExpandedNavigationTitle` from `Your Rewards` to
      `Your Collection`
- [x] 8.2 Delete `MedalGrid.swift`, `MedalGridSection.swift`, `MedalCard.swift`, and
      `MedalStatsSection.swift`, and confirm by grep that nothing outside the medals
      feature referenced them — `StatCard` itself stays for `ProfileSummarySection`
- [x] 8.3 Verify the add-medal and error-presentation flows in `MedalsView` still work
      unchanged, including the reload on `AddMedalView` dismissal

## 9. Localization

- [x] 9.1 Add `Your Collection`, `All`, `No time recorded`, and `PR` to
      `Localizable.xcstrings` with `zh-TW` translations
- [x] 9.2 Add the per-year medal count as a plural-varied String Catalog entry so `1 medal`
      and `2 medals` both read correctly, and confirm the `zh-TW` variant is right for a
      language without plural inflection
- [x] 9.3 Extend `StringCatalogTests` / `LocalizationTests` to cover the new keys

## 10. Verification

- [x] 10.1 Run the full test suite — `xcodebuild test -project MedalWall.xcodeproj -scheme
      MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` — and confirm it
      passes
- [ ] 10.2 Build and check the screen against `Medal Wall iOS v4.3.html` in both light and
      dark appearance, confirming the deliberate divergences from design.md Decision 8 are
      the only ones
- [x] 10.3 Verify against the sample data that the PR marker lands on the fastest medal in
      each category and nowhere else
- [x] 10.4 Confirm SwiftLint and swift-format pass on the changed files
