## 1. Pace Formatting

- [x] 1.1 Write failing tests in `DistanceUnitTests` for `paceValueText(
      minutesPerKilometer:)`: it returns the value alone with no unit, truncates seconds the
      way `paceText` does, converts per-mile when the unit is miles, and returns `nil` for
      a `nil` pace — the unfilled wording belongs to the caller, not to a unit
- [x] 1.2 Write a failing test that `paceText` still returns value and abbreviation joined,
      so composing it from the new function changes nothing for its existing caller
- [ ] 1.3 Add `paceValueText(minutesPerKilometer:)` to `DistanceUnit` and recompose
      `paceText` from it plus `abbreviation()`, so the pace format is written once
      (design.md Decision 5)

## 2. ViewModel

- [x] 2.1 Write failing tests in `MedalDetailViewModelTests` that `isPersonalRecord` is
      taken from `init` and defaults to `false`
- [x] 2.2 Write failing tests for the division label: a medal with a division composes
      `Division` plus its group, and a medal without one reads the plain `Division`
      (design.md Decision 3)
- [x] 2.3 Write failing tests for unfilled fields: pace, overall, gender and division each
      read the em dash when unrecorded, and `finishTimeText` reads `No time recorded`
      rather than a placeholder character (spec: The Result Is Always Fully Stated)
- [x] 2.4 Write failing tests that a suffix is `nil` whenever its value is unfilled — a
      recorded total with no placement must not render `— / 7373`
- [x] 2.5 Write failing tests for the filled shape: `1058` with `/ 7373`, `233` with
      `/ 6081`, `523` with `/ 1633`, and pace value with its unit
- [x] 2.6 Add `isPersonalRecord` to `MedalDetailViewModel.init`, add `divisionLabel`,
      `averagePaceValue` / `averagePaceUnit`, and change the placement properties to return
      the em dash and optional suffixes. Keep the project's `// MARK:` order

## 3. Result Item & Section

- [x] 3.1 Build `MedalDetailResultItem` (`Features/Medal/MedalDetail/Views/`) replacing
      `MedalDetailStatsGridItem` — `label`, `value`, optional `suffix`, `isRecord`. Value
      in `Font.TypeScale.Numeric.large`, suffix in `microLabel` at `Text.secondary`, label
      in `microLabel` with call-site `.tracking()` / `.textCase(.uppercase)`
      (design.md Decision 8)
- [x] 3.2 Show the `PR` marker beside the value via `.tagStyle(.record)` when `isRecord`.
      Do not carry over `headLineColor`: a finish time is ink, never gold
- [x] 3.3 Build `MedalDetailResultSection` replacing `MedalDetailStatsSection` — a
      `PageSection` titled `The result` over a two-column grid, Finish spanning both
      columns, then avg pace, overall, gender, division
- [x] 3.4 Delete `MedalDetailStatsGridItem.swift` and `MedalDetailStatsSection.swift`, and
      confirm by grep that nothing outside the medal detail feature referenced them
- [x] 3.5 Add `#Preview`s for the item and the section covering a fully recorded medal, a
      finish-time-only medal, and an untimed medal

## 4. Hero & Facts

- [ ] 4.1 Rewrite `MedalDetailHeroSection` to lay itself out — centred
      `PhotoImage(as: .medal)` with `.medalRing()`, above the race name in `title1`
      uppercase, wrapping rather than truncating (spec: A long race name stays legible).
      Do not change `DetailHeroSection`, which `RaceDetailHeroSection` still uses
      (design.md Decision 6)
- [ ] 4.2 Build `MedalDetailFactRow` — label left in `microLabel` uppercase with tracking,
      value right in `caption`, with an optional secondary line beneath the value for the
      race type
- [ ] 4.3 Build `MedalDetailFactsSection` composing Location, Date, Distance (with race
      type) and Bib, with a hairline above every row but the first
- [ ] 4.4 Add `#Preview`s for the hero (short name, long wrapping name) and the facts
      section

## 5. The Day & Tags

- [ ] 5.1 Build `MedalDetailDaySection` composing the existing event photo strip and note
      under one `PageSection` titled `The day` (design.md Decision 7)
- [ ] 5.2 Keep the photo strip's tap-to-open `PhotoViewer` behaviour and the note's
      surface treatment exactly as they are today
- [ ] 5.3 Render the band when the medal has photos, a note, or both, and omit it entirely
      when it has neither (spec: One without the other still reads as the day)
- [ ] 5.4 Change `MedalDetailTagsSection` to `.chipStyle(.neutral)` capsules
      (spec: Tags Are Presented As Capsules)
- [ ] 5.5 Add `#Preview`s for the day section covering photos only, note only, and both

## 6. Screen Wiring

- [ ] 6.1 Recompose `MedalDetailView` — hero, facts, result, day, tags — and add
      `isPersonalRecord` to its `init`, passing it to the view model
- [ ] 6.2 Drop the inline navigation title so the race name is not stated twice, keeping
      the back button's automatic title
- [ ] 6.3 Pass `personalRecordIDs.contains(medal.id)` from `MedalYearSection` and `true`
      from `MedalPersonalBestCarousel` (design.md Decision 1)
- [ ] 6.4 Verify the edit sheet, delete confirmation, error presentation and
      `reloadMedal()` on dismissal all still work unchanged

## 7. Localization

- [ ] 7.1 Add `The result`, `The day`, `Location`, `Date`, `Distance`, `Bib`, `Finish`,
      `Avg pace`, `Overall`, `Gender` and `Division` to `Localizable.xcstrings` with
      `zh-TW` translations
- [ ] 7.2 Confirm the composed division label reads correctly in `zh-TW`, where the group
      follows rather than precedes the stem
- [ ] 7.3 Extend `StringCatalogTests` to cover the new keys

## 8. Verification

- [ ] 8.1 Run the full test suite — `xcodebuild test -project MedalWall.xcodeproj -scheme
      MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` — and confirm it
      passes
- [ ] 8.2 Check the screen against `Medal Wall iOS v4.3.html` in light, dark and `zh-TW`,
      confirming the design.md Decision 8 divergences are the only ones
- [ ] 8.3 Check a `1058 / 7373` medal on device for the crowding risk design.md names, and
      a medal with only a finish time for the always-present grid
- [ ] 8.4 Verify the `PR` marker appears when opened from a record-holding row and from the
      carousel, and is absent on a non-record medal
- [ ] 8.5 Confirm SwiftLint and swift-format pass on the changed files
