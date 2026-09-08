## 1. Value Type

- [x] 1.1 Write failing tests for `MedalPersonalBest`: `id` is `category.value`, two
      entries built from the same distance are equal in identity regardless of the medal
      they hold, and an entry built from `.custom(42.195)` shares an id with one built
      from `.full` (design.md Decision 2)
- [x] 1.2 Implement `MedalPersonalBest` (`Features/Medal/Models/`) — `Identifiable`,
      holding `category: RaceDistanceCategory` and `medal: Medal`, with
      `var id: Double { category.value }`

## 2. Ordered Projection

- [x] 2.1 Write failing tests for `personalBests` ordering: entries come back longest
      distance first, in the same order `distanceCategoriesOwned` returns
      (spec: Personal Best Presentation)
- [x] 2.2 Write failing tests that each entry holds exactly the medal `personalRecords`
      names for that category — the projection must not re-derive the record
- [x] 2.3 Write failing tests for omission: a category whose medals are all untimed yields
      no entry while other categories still do, a fully untimed collection yields an empty
      array, and an empty collection yields an empty array
- [x] 2.4 Write a failing test that a custom distance equal to a preset collapses onto that
      preset's single entry rather than producing two (design.md Decision 1)
- [x] 2.5 Implement `personalBests` in `Medal+Stats.swift` as an
      `Array where Element == Medal` extension, walking `distanceCategoriesOwned` and
      `compactMap`-ing `personalRecords` — do not sort the dictionary's keys separately

## 3. ViewModel

- [ ] 3.1 Write a failing test in `MedalsViewModelTests` that `personalBests` is unchanged
      by `selectedFilter` — narrowing to one category returns the same entries in the same
      order as `.all` (spec: Personal Best Presentation Is Independent Of The Distance
      Filter)
- [ ] 3.2 Write a failing test that `personalBests` is empty for an empty collection and
      for one where no medal has an eligible finish time
- [ ] 3.3 Add `personalBests` to `MedalsViewModel` as a computed property delegating to
      `medals.personalBests`, reading `medals` and never the filtered set (design.md
      Decision 3). Keep the project's `// MARK:` order

## 4. Card

- [ ] 4.1 Build `MedalPersonalBestCard` (`Features/Medal/Medals/Views/`) taking formatted
      strings only — `distance`, `finishTime`, `raceName`, `pace`. Header row is
      `Personal best` in `sectionTitle` with call-site `.tracking()` / `.textCase(.uppercase)`,
      a spacer, then the distance in `microLabel` treated the same way
- [ ] 4.2 Render the finish time in `Font.TypeScale.Numeric.large` and the meta line —
      race name, pace — in `microLabel`, per design.md Decision 8. Do not reproduce the
      mockup's off-scale 34px and 9px
- [ ] 4.3 Show the `PR` marker on the meta line via `.tagStyle(.record)`, and give the card
      `.surfaceStyle()` for its radius, padding and border
- [ ] 4.4 Add `#Preview`s for the card: a long race name that must wrap, and a custom
      distance so the unit-resolved label is visible

## 5. Carousel

- [ ] 5.1 Build `MedalPersonalBestCarousel` (`Features/Medal/Medals/Views/`) taking
      `[MedalPersonalBest]` and a `Namespace.ID`, mapping each entry onto a
      `MedalPersonalBestCard` the way `MedalYearSection` maps a `Medal` onto a `MedalRow`
      (design.md Decision 3) — `finishTime` via `formattedHMS`, `distance` via
      `category.description`, `pace` via
      `MedalDetailViewModel.paceText(minutesPerKilometer:in:)` over `medal.averagePace`
      (design.md Decision 4)
- [ ] 5.2 Lay the cards out full width: `.containerRelativeFrame(.horizontal)` on the card,
      `.scrollTargetLayout()` on the `HStack`, `.scrollTargetBehavior(.viewAligned)` and
      `.contentMargins(.horizontal, .Space.gutter, for: .scrollContent)` on the
      `ScrollView`
- [ ] 5.3 Render nothing at all — no frame, no padding — when the entries are empty
      (spec: a collection with no records presents nothing)
- [ ] 5.4 Wrap each card in a `NavigationLink` to `MedalDetailView(medal:)` with
      `.navigationTransition(.zoom(sourceID:in:))` and
      `.matchedTransitionSource(id: "personalBest-\(medal.id)", in: namespace)` — the
      prefix is what keeps it from colliding with the same medal's row anchor
      (design.md Decision 7)
- [ ] 5.5 Add the page indicator: dots in `Color.Text.secondary`, dimmed for pages that are
      not current, tracked with `.scrollPosition()`, and omit the row entirely when there
      is one entry (spec: Multiple Personal Bests Are Discoverable)
- [ ] 5.6 Add `#Preview`s for the carousel covering one record, several records, and none

## 6. Screen Wiring

- [ ] 6.1 Add `MedalPersonalBestCarousel` to `MedalList`'s existing
      `.safeAreaInset(edge: .top)`, above `MedalDistanceFilterBar` in a `VStack`, passing
      the view model's `personalBests` and the existing `@Namespace` (design.md Decision 5)
- [ ] 6.2 Verify by inspection that the filter bar, year sections, empty state, and the
      reload on `AddMedalView` dismissal are untouched, and that the list still scrolls
      under the pinned carousel
- [ ] 6.3 Confirm the carousel is absent — not merely empty — on a collection with medals
      but no finish times, so the filter bar keeps its position

## 7. Localization

- [ ] 7.1 Add `Personal best` to `Localizable.xcstrings` with its `zh-TW` translation
- [ ] 7.2 Extend `StringCatalogTests` / `LocalizationTests` to cover the new key

## 8. Verification

- [ ] 8.1 Run the full test suite — `xcodebuild test -project MedalWall.xcodeproj -scheme
      MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro'` — and confirm it
      passes
- [ ] 8.2 Check the screen against `Medal Wall iOS v4.3.html` in both light and dark
      appearance, confirming the design.md Decision 8 divergences are the only ones
- [ ] 8.3 Verify against the sample data that each card names the same medal its row wears
      the `PR` tag on, and that paging a card leaves the filter selection and the list
      untouched
- [ ] 8.4 Confirm SwiftLint and swift-format pass on the changed files
