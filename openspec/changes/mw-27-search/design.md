## Context

`ContentView` has three tabs: You, Medal and Race. Each tab fetches its own data when it
appears and filters in memory: `MedalsViewModel.loadMedals(userId:)` fetches the user's medals,
`RacesViewModel.loadRaces()` fetches every race. The Races list carries the app's only search:
`.searchable` bound to `RacesViewModel.searchText`, matching race names with
`localizedStandardContains`, which ignores case and diacritics, works the same for English and
Chinese, and finds the text anywhere in the name.

iOS mockup v4.7.2 draws the Search tab: the tab bar, the empty field, typing, results and no
results, in light and dark. Its layout, copy, states and notes are what this change builds.

## Goals / Non-Goals

**Goals:**
- One field that finds the user's medals and any race by name or place.
- Results that update on every keystroke, in one list, with no extra screen to reach a match.
- The Races list's search behaviour carried over, so a query finds what it found there.

**Non-Goals:**
- Filters, browsing by place or distance, recent searches, suggestions.
- Searching tags, notes, bib numbers, results or anything other than name and place.
- Searching other users' medals.
- A server-side or indexed search; Firestore query changes.
- Skeleton bones on the Search tab.

## Decisions

### The tab
`ContentView` adds a fourth tab, last: `Tab("Search", systemImage: "magnifyingglass", role:
.search) { SearchView() }`. With the search role, iOS 26 draws it as the separate circle beside
the You · Medal · Race pill and moves the search field to the bottom bar; its clear and close
buttons are the system's. Nothing in the tab bar or the field is hand-built.

### Where the code lives
`MedalWall/Features/Search/`, following the other feature folders:
- `Views/SearchView.swift` — the screen: its own `NavigationStack`, `.searchable(text:prompt:)`
  with the prompt "Search races and medals" and `.autocorrectionDisabled()` as the Races list
  had it, so a race name is never corrected away, the "Search" large title (inline-large with
  `ExpandedNavigationTitle`, as Medals and Races), the error-sheet bridge, and the switch between
  the hint, the results and no results.
- `Views/SearchResultList.swift` — the `List` with the two sections.
- `Views/SearchSectionHeader.swift` — a section title (`sectionTitleStyle()`) and its count.
- `Views/SearchMedalRow.swift`, `Views/SearchRaceRow.swift` — the compact rows the mockup draws.
- `ViewModels/SearchViewModel.swift`.

Matching and ordering live with the models, as array extensions:
`Models/Medal/Medal+Search.swift` and `Models/Race/Race+Search.swift`.

### Loading
`SearchViewModel.load(userId:)` fetches the races and the user's medals concurrently (`async
let`), through `RaceRepository.fetchRaces()` and `MedalRepository.fetchMedals(userId:)`. Each
fetch handles its own failure, so a failed medal fetch still lets races arrive and the reverse.
With no signed-in user id the medal fetch is skipped and counts as finished.

`SearchView` starts a load in `.onAppear` with an unstructured `Task`, as `MedalsView` does —
not `.task`, which cancels the fetch when a pushed detail screen makes the root disappear and
would surface the cancellation as a fetch failure. `onAppear` fires when the tab is selected and
when the user returns from a detail screen, so a medal or race added, edited or deleted anywhere
shows up the next time Search is on screen.

A reload replaces the arrays when it finishes; until then the previous results stay on screen.
There is no skeleton and no spinner: a section appears when its data arrives.

### Matching
The query is the field's text trimmed of `.whitespacesAndNewlines`. An empty query shows the
hint. Otherwise a medal or race matches when `localizedStandardContains(query)` holds for its
`name` or for `place.formatted` — the place exactly as the app displays it, so what the user can
read on screen is what they can find. Medals match against the user's own collection; races
against every race.

### Ordering
- **Your Collection:** the matches in `sortedForDisplay` order — newest first, ties by `id` —
  the Medal tab's order.
- **Races:** races whose name matches first, then races that match only by place. Each group is
  sorted by `name.localizedCompare` ascending, as the Races list sorts, with ties broken by
  `id` so equal names never swap between loads.

### SearchViewModel
- **Data:** `medals`, `races`.
- **State:** `error: AppError?`, and whether each fetch has finished at least once
  (succeeded or failed). Together these give `isAwaitingFirstLoad`.
- **Filter:** `searchText`.
- **Dependencies:** `any MedalRepository`, `any RaceRepository`, defaulting to the Firestore
  implementations, as the other view models take them.
- **Computed:** `query` (trimmed), `isQueryEmpty`, `matchingMedals`, `matchingRaces` (with
  `editionCount` clamped to `max(0, …)` as the Races list does), `personalRecordIDs` (from the
  **whole** collection, not the matches), and `isShowingNoResults` — a non-empty query, no
  matches in either section, and not `isAwaitingFirstLoad`. A reload does not hide a "No
  Results" already shown.

### Screen states
| Condition | Shown |
|---|---|
| query empty | the hint: "Search Races and Medals" / "Find any race by name, city or country." with a magnifying-glass symbol, centred, and nothing else |
| any matches | `SearchResultList` |
| `isShowingNoResults` | `ContentUnavailableView.search(text: query)` |
| no matches yet, first load still running | an empty background — no hint, no "No Results" |

The hint is an `EmptyState` with the magnifying-glass symbol: `EmptyState` takes a
`systemImage`, defaulting to the tray its other screens show, so every empty state keeps one
type and colour treatment.

### Results list
One `List` with up to two `Section`s, Your Collection then Races. A section with no matches is
left out. Each header is `SearchSectionHeader(title:count:)`: the title in
`sectionTitleStyle()` and the match count beside it, formatted with grouping ("1,846"). Rows
sit on `Color.Surface.primary`, as the Races list's rows do. `List` builds rows lazily, so
neither section is capped.

### Rows
Both rows follow the mockup: an image, then a bold name and two secondary lines. The image
takes the same 52 pt footprint in both sections, so the two sections' text columns line up.
`PhotoImage` takes its size from `ImageType`, so this is one new `ImageType` case per asset: a
search-row race image of 52 pt, and a search-row medal photo of 46 pt that `.medalRing()`'s
3 pt ring brings to 52, as `medalThumbnail` (96 pt) and its ring make the Medal list's 102 pt
circle. `ImageTypeTests` covers both.
- **`SearchMedalRow`:** the medal photo in its gold ring (`.medalRing()`), the name, the date
  (`formattedMonthDayYear()`), and the distance label with the finish time —
  `"\(raceEvent.displayLabel) · \(finishTime.formattedHMS)"`, or the distance label alone when
  no time is recorded. No PR tag: the row stays one line shorter than the Medal tab's.
- **`SearchRaceRow`:** the race photo, the name, `place.formatted`, and the inflected edition
  count, as `RaceRow` shows it.

Neither row carries swipe actions. Deleting stays on the Races list and the detail screens.

### Opening a result
A medal row is a `NavigationLink` to `MedalDetailView(medal:personalRecordIDs:)` with the
view model's whole-collection `personalRecordIDs`. A race row is a `NavigationLink` to
`RaceDetailView(race:)`.

### Errors
A failed medal fetch sets `.medalFetchFailed`, a failed race fetch `.raceFetchFailed`. The view
presents them through the project's `ErrorWrapper` bridge and resets `error` on dismiss. The
section whose data did load stays searchable.

### The Races list
- `RacesView` drops `.searchable` and `.autocorrectionDisabled()`.
- `RacesViewModel` drops `searchText`. `filteredRaces` no longer filters, so it becomes
  `sortedRaces`: sorted by name, `editionCount` clamped.
- `RaceList` drops its `searchText` parameter and its no-search-results branch, and
  `RaceNoResultState.swift` is deleted.
- The three catalog keys only the Races search used — "Search race events...",
  "No race events match '%@'" and "No Results" — are removed from `Localizable.xcstrings`.

### Localization
New keys in `Localizable.xcstrings`, with zh-TW:
| Key | zh-TW |
|---|---|
| Search | 搜尋 |
| Search Races and Medals | 搜尋賽事與獎牌 |
| Find any race by name, city or country. | 依名稱、城市或國家尋找任何賽事。 |
| Search races and medals | 搜尋賽事與獎牌 |

"Your Collection" (我的收藏) and "Races" (賽事) already exist. `ContentUnavailableView.search`
is the system's own text. Keys are added by script in `localizedStandardCompare` order, and
`StringCatalogTests` gains a test that Search's keys ship translated.

## Risks / Trade-offs

- [A one- or two-letter query matches most races — "t" finds nearly all of them] → Results
  update per keystroke, so the next letter narrows them; `List` keeps the long list smooth.
- [Matching on every keystroke recomputes `place.formatted` for every race, which looks up a
  localized country name; at thousands of races this may lag typing] → Filtering stays in the
  view model, so a search key per race computed once per load can replace the per-keystroke
  formatting without touching the views, if profiling on a device shows the lag.
- [Fetching every race each time Search appears costs a Firestore read per race] → The Races
  tab already does this; both move together if the app ever pages or caches races.
- [`place.formatted` follows the device locale, so a country is found only by the name the app
  displays — "Taiwan" on an English device, "台灣" on a Chinese one] → It matches what the row
  shows, so the user always searches for text they can see.
- [A medal edited from its detail screen may no longer match the query when the user returns]
  → The reload on return applies the query to the edited medal, and it leaves the list.
