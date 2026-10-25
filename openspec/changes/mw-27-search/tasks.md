## 1. Matching and ordering

- [ ] 1.1 Write failing tests for `Medal+Search.swift`: a medal matches on its name or its
      `place.formatted`, anywhere in the text, ignoring case and diacritics ("zurich" →
      "Zürich"), Chinese anywhere ("馬拉松" → "田中馬拉松"); the matches come back in
      `sortedForDisplay` order (design.md, Matching and Ordering)
- [ ] 1.2 Create `Features/Search/Models/Medal+Search.swift` to pass them
- [ ] 1.3 Write failing tests for `Race+Search.swift`: the same matching rules; name matches
      before place-only matches ("Taipei Marathon" before "Banqiao Night Run" for "Taipei");
      each group A→Z by `localizedCompare`; equal names ordered by `id` whatever the input order
- [ ] 1.4 Create `Features/Search/Models/Race+Search.swift` to pass them
- [ ] 1.5 Add both files to the test target's `membershipExceptions` in `project.pbxproj`;
      `plutil -lint` it (memory: test target include list)

## 2. SearchViewModel

- [ ] 2.1 Write failing tests with `StubMedalRepository` and `StubRaceRepository`: `load(userId:)`
      fetches both; a nil user id skips medals; the query is trimmed of whitespace and
      newlines; an empty or whitespace-only query is `isQueryEmpty` with no matches;
      `matchingRaces` clamps a negative `editionCount` to 0; `personalRecordIDs` comes from the
      whole collection, so a slower medal is not a record when the query misses the faster one
- [ ] 2.2 Write failing tests for `isShowingNoResults`: false while either first load is held
      (`FetchHold`), true once both finish with no match, still true during a held reload;
      false for an empty query
- [ ] 2.3 Write failing tests for failures: a failed race fetch sets `.raceFetchFailed` and the
      medals still match; a failed medal fetch sets `.medalFetchFailed` and the races still
      match; a failed fetch counts as finished for `isShowingNoResults`; a reload keeps the
      previous arrays until it completes
- [ ] 2.4 Create `Features/Search/ViewModels/SearchViewModel.swift` to pass 2.1–2.3 (design.md,
      SearchViewModel and Loading); add it to the test target's `membershipExceptions`

## 3. Search screen

- [ ] 3.1 Create `SearchSectionHeader` (title in `sectionTitleStyle()`, count with grouping),
      with previews
- [ ] 3.2 Write a failing `ImageTypeTests` case for the two search-row image types (one size
      for both, circle for the medal, rounded rect for the race), then add them to `ImageType`
- [ ] 3.3 Create `SearchMedalRow` and `SearchRaceRow` per the mockup and design.md, Rows: both
      sections share one image size; the medal's third line is "distance · time" or the
      distance alone; the race shows the inflected edition count. Previews: timed, untimed,
      race with and without a photo
- [ ] 3.4 Create `SearchResultList`: one `List`, Your Collection then Races, a section left out
      when empty, rows on `Color.Surface.primary`; medal rows link to
      `MedalDetailView(medal:personalRecordIDs:)` with the zoom transition, race rows to
      `RaceDetailView(race:)`; no swipe actions. Previews: both sections, races only
- [ ] 3.5 Create `SearchView`: its own `NavigationStack`, "Search" large title,
      `.searchable(text:prompt:)` with "Search races and medals", the hint for an empty query,
      `ContentUnavailableView.search(text:)` when `isShowingNoResults`, an empty background
      otherwise while nothing matches; load in `.onAppear` with an unstructured `Task`; the
      error-sheet bridge. Named previews: hint, results, no results
- [ ] 3.6 Add `Tab("Search", systemImage: "magnifyingglass", role: .search)` as the last tab in
      `ContentView`

## 4. Races list loses its search

- [ ] 4.1 Update `RacesViewModelTests` and `RacesViewModelRepositoryTests`: delete the
      search-text tests, rename `filteredRaces` to `sortedRaces` in the rest; watch them fail
- [ ] 4.2 Remove `searchText` from `RacesViewModel` and rename `filteredRaces` to
      `sortedRaces`, sorting and clamping only
- [ ] 4.3 Remove `.searchable` and `.autocorrectionDisabled()` from `RacesView`; remove
      `RaceList`'s `searchText` parameter, its no-search-results branch and preview; delete
      `RaceNoResultState.swift`

## 5. Localization

- [ ] 5.1 Write a failing `StringCatalogTests` test that Search's keys ship translated in zh-TW
- [ ] 5.2 Add "Search", "Search Races and Medals", "Find any race by name, city or country." and
      "Search races and medals" with the zh-TW values in design.md, Localization; remove "Search
      race events..." and "No race events match '%@'" (memory: String Catalog editing)

## 6. Verify

- [ ] 6.1 Run the full test suite and the build; confirm the new test names ran (memory:
      xcodebuild can run stale tests)
- [ ] 6.2 On the simulator, in English and zh-TW, light and dark: the Search circle beside the
      tab bar; the hint; "t" listing many results smoothly; "Taipei" grouping name matches
      before place matches; a Chinese query; "No Results"; opening a medal and a race and going
      back with the query kept; the Races list with no search field
- [ ] 6.3 Run `design-system-check` (the change adds UI) and record any deliberate deviation in
      `openspec/design-system/deviations.md`
