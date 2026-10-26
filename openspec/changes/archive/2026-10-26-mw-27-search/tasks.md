## 1. Matching and ordering

- [x] 1.1 Write failing tests for `Medal+Search.swift`: a medal matches on its name or its
      `place.formatted`, anywhere in the text, ignoring case and diacritics ("zurich" →
      "Zürich"), Chinese anywhere ("馬拉松" → "田中馬拉松"); the matches come back in
      `sortedForDisplay` order (design.md, Matching and Ordering)
- [x] 1.2 Create `Models/Medal/Medal+Search.swift` to pass them
- [x] 1.3 Write failing tests for `Race+Search.swift`: the same matching rules; name matches
      before place-only matches ("Taipei Marathon" before "Banqiao Night Run" for "Taipei");
      each group A→Z by `localizedCompare`; equal names ordered by `id` whatever the input order
- [x] 1.4 Create `Models/Race/Race+Search.swift` to pass them
- [x] 1.5 Add both files to the test target's `membershipExceptions` in `project.pbxproj`;
      `plutil -lint` it (memory: test target include list)

## 2. SearchViewModel

- [x] 2.1 Write failing tests with `StubMedalRepository` and `StubRaceRepository`: `load(userId:)`
      fetches both; a nil user id skips medals; the query is trimmed of whitespace and
      newlines; an empty or whitespace-only query is `isQueryEmpty` with no matches;
      `matchingRaces` clamps a negative `editionCount` to 0; `personalRecordIDs` comes from the
      whole collection, so a slower medal is not a record when the query misses the faster one
- [x] 2.2 Write failing tests for `isShowingNoResults`: false while either first load is held
      (`FetchHold`), true once both finish with no match, still true during a held reload;
      false for an empty query
- [x] 2.3 Write failing tests for failures: a failed race fetch sets `.raceFetchFailed` and the
      medals still match; a failed medal fetch sets `.medalFetchFailed` and the races still
      match; a failure while an error is set keeps the first, so both failing sets one error;
      a failed fetch counts as finished for `isShowingNoResults`; a reload keeps the previous
      arrays until it completes; a load that lands after a newer one started changes neither
      the data, the error nor whether the fetch counts as finished (the stubs answer a held
      fetch with the data held when it started, and `FetchHold` can hold two fetches at once)
- [x] 2.4 Create `Features/Search/ViewModels/SearchViewModel.swift` to pass 2.1–2.3 (design.md,
      SearchViewModel and Loading); add it to the test target's `membershipExceptions`

## 3. Search screen

- [x] 3.1 Create `SearchSectionHeader` (title in `sectionTitleStyle()`, count with grouping),
      with previews
- [x] 3.2 Write a failing `ImageTypeTests` case for the two search-row image types (the ringed
      medal and the race share one footprint, circle for the medal, rounded rect for the race),
      then add them to `ImageType`
- [x] 3.3 Create `SearchMedalRow` and `SearchRaceRow` per design.md, Rows: both sections share
      one image footprint; the medal shows its date, name, place and distance, each on its own
      line; the race shows the inflected edition count. Previews: a medal with a standard and
      with a long custom distance, a race with one and with several editions
- [x] 3.4 Create `SearchResultList`: one `List`, Your Collection then Races, a section left out
      when empty, rows on `Color.Surface.primary`; medal rows link to
      `MedalDetailView(medal:personalRecordIDs:)`, race rows to `RaceDetailView(race:)`; no
      swipe actions. Previews: both sections, races only
- [x] 3.5 Create `SearchView`: its own `NavigationStack`, "Search" large title,
      `.searchable(text:prompt:)` with "Search races and medals", the hint (`EmptyState` with a
      `systemImage`) for an empty query, `ContentUnavailableView.search(text:)` when
      `isShowingNoResults`, an empty background otherwise while nothing matches; load in
      `.onAppear` with an unstructured `Task`; the error-sheet bridge. Preview: the hint (the
      view model is the screen's own; `SearchResultList` previews the results)
- [x] 3.6 Add `Tab("Search", systemImage: "magnifyingglass", role: .search)` as the last tab in
      `ContentView`

## 4. Races list loses its search

- [x] 4.1 Update `RacesViewModelTests` and `RacesViewModelRepositoryTests`: delete the
      search-text tests, rename `filteredRaces` to `sortedRaces` in the rest; watch them fail
- [x] 4.2 Remove `searchText` from `RacesViewModel` and rename `filteredRaces` to
      `sortedRaces`, sorting and clamping only; the clamp is `withClampedEditionCounts` in
      `Race+Computed.swift`, tested in `RaceComputedTests` and shared with `SearchViewModel`
- [x] 4.3 Remove `.searchable` and `.autocorrectionDisabled()` from `RacesView`; remove
      `RaceList`'s `searchText` parameter, its no-search-results branch and preview; delete
      `RaceNoResultState.swift`

## 5. Localization

- [x] 5.1 Write failing `StringCatalogTests` tests that Search's keys ship translated in zh-TW and
      the Races search's keys are gone
- [x] 5.2 Add "Search", "Search Races and Medals", "Find any race by name, city or country." and
      "Search races and medals" with the zh-TW values in design.md, Localization; remove "Search
      race events...", "No race events match '%@'" and "No Results" (memory: String Catalog
      editing)

## 6. Verify

- [x] 6.1 Run the full test suite and the build; confirm the new test names ran (memory:
      xcodebuild can run stale tests)
- [x] 6.2 On the simulator, in English and zh-TW, light and dark: the Search circle beside the
      tab bar; the hint; "t" listing many results smoothly; "Taipei" grouping name matches
      before place matches; a Chinese query; "No Results"; opening a medal and a race and going
      back with the query kept; the Races list with no search field
- [x] 6.3 Run `design-system-check` (the change adds UI) and record any deliberate deviation in
      `openspec/design-system/deviations.md`
