## Why

The only way to find something today is the search field on the Races list, which matches race
names and nothing else. Finding one of your own medals means scrolling the collection year by
year. iOS mockup v4.7.2 now designs a Search tab that searches your medals and every race from
one field (Jira MW-27). This change builds that basic search; filters, browsing and recent
searches are later phases.

## What Changes

- A **Search tab** joins You, Medal and Race, declared with the system's search tab role so iOS
  draws it as the separate circle beside the tab bar.
- **Empty field:** a hint (title and description) and nothing else — no recent searches,
  suggestions or filters.
- **Matching:** results update on every keystroke. A medal or race matches when the typed text
  appears anywhere in its name or in its place as the app displays it, ignoring case and
  diacritics — the rule the Races list's search uses today, widened to the place.
- **Results:** one list with two sections: **Your Collection** (the signed-in user's matching
  medals, newest first) then **Races** (every matching race; races whose name matches come before
  races that match only by place, each group A→Z). Each section header shows its match count; a
  section with no matches is hidden. Neither section is capped.
- **No results:** the system's no-results view naming the query, shown only once nothing is
  still loading.
- **Opening a result** pushes the existing Medal Detail or Race Detail on the Search tab's own
  navigation stack.
- **Data:** Search loads the races and the user's medals itself each time it appears, the way the
  Medal and Race tabs do, and filters on the phone. It shows no skeleton.
- **BREAKING (UI):** the Races list drops its search field; the Search tab replaces it.

## Capabilities

### New Capabilities
- `search`: the Search tab — what is searched, how a query matches, how results are grouped,
  ordered and counted, the empty-field, no-results, loading and failure states, and where a
  result leads.

### Modified Capabilities
_None._ No existing spec states a requirement for the Races list's search field, so removing it
changes no requirement. The `search` spec records that the Races list has none.

## Impact

- **Root view:** `ContentView` gains the Search tab.
- **New feature folder** `MedalWall/Features/Search/`: `SearchView`, `SearchViewModel`, and the
  compact result rows and section header the mockup draws.
- **Races list:** `RacesView` loses `.searchable`; `RacesViewModel` loses `searchText`;
  `RaceList` loses its no-search-results branch; `RaceNoResultState` is deleted. Their tests are
  updated to match.
- **Tests:** new `SearchViewModel` tests using the existing repository stubs;
  `project.pbxproj`'s test-target membership list gains the new files the tests compile.
- **Localization:** the tab label, hint, prompt and section titles in English and zh-TW.
- No Firestore schema, repository, design-token or dependency changes.
