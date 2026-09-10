## Why

The medal list is a two-column grid of equal-weight cards sorted by nothing in
particular — Firestore returns documents unordered and `MedalGrid` renders them in
arrival order. A collection is a record of a running career, and the grid flattens it:
there is no sense of when a medal was earned relative to the others, no way to look at
one distance on its own, and nothing marks the times the user actually worked for.
Design system v4.3 replaces it with a list grouped by year, a distance filter, and a
single earned marker. Tracked in Jira [MW-30](https://quien.atlassian.net/browse/MW-30).

## What Changes

- **BREAKING (display only):** the two-column grid becomes a single-column list grouped
  by year, newest year first and newest medal first within a year. `MedalCard` is
  replaced by a wider row — a 96pt ringed thumbnail beside date, race name, distance,
  and finish time — because a grid cell has no room for the year context or the finish
  time at a readable size.
- Each year group carries a header: the year, a rule, and the count of medals in it.
- Add a distance filter strip above the list. Chips are derived from the distance
  categories the user actually owns, `All` first and then longest distance first, each
  carrying its count. A user whose collection is all 10Ks sees `All / 10K`, not three
  chips reading zero.
- Because the chips are derived from owned categories, selecting one can never produce
  an empty list. The screen has exactly one empty state — a collection with no medals at
  all — and it keeps the existing `MedalEmptyView`.
- Mark each distance category's best finish time with the champagne `PR` tag. A personal
  record is **derived, never stored**: it is the minimum non-nil `finishTime` within a
  `RaceDistanceCategory`, ties broken by the earlier date, medals without a finish time
  excluded entirely.
- Show `No time recorded` in place of the finish time when a medal has none, rather than
  the current `-` placeholder.
- Sort and group in `MedalsViewModel`. `MedalFirestoreRepository.fetchMedals` returns
  documents unordered today, which the grid tolerated and a year-grouped list cannot.
- **Removed:** `MedalStatsSection` and its three `StatCard`s. It reported Total / Full /
  Half immediately above a list whose filter chips now report the same numbers; keeping
  both would state one fact twice. `StatCard` itself stays — `ProfileSummarySection`
  uses it.
- The navigation title becomes `Your Collection`, replacing `Your Rewards`.
- No Firestore schema change. `Medal` gains no `isPR` field and no `raceId`; everything
  the screen needs is already persisted.

## Capabilities

### New Capabilities
- `medal-browsing`: How a user's medal collection is presented as a whole rather than one
  medal at a time — the year grouping and its ordering, the distance filter and how its
  options are derived from the collection, what a personal record is and which medal
  carries the marker, and the guarantee that a filter selection always has something to
  show.

### Modified Capabilities
<!-- None. The `medals` capability covers creating, reading, updating and deleting a
     single Medal and the privacy scope of a fetch; none of those requirements change.
     This change only adds how the fetched set is presented. -->

## Impact

- **New** `Features/Medal/Models/MedalDistanceFilter.swift` — `.all` / `.category(_)`,
  the chip selection state.
- **New** `Features/Medal/Models/MedalYearGroup.swift` — `Identifiable` pairing of a year
  with its medals, so `ForEach` has a stable identity.
- **New** views in `Features/Medal/Medals/Views/`: `MedalList` (replaces `MedalGrid`),
  `MedalDistanceFilterBar`, `MedalYearSection` (replaces `MedalGridSection`),
  `MedalYearHeader`, `MedalRow` (replaces `MedalCard`).
- **Modified** `Models/Medal/Medal+Stats.swift` — joins the existing `fullCount` /
  `halfCount` / `bestFullTime` / `bestHalfTime` array extensions with personal-record
  resolution, year grouping, and per-category counts. This is where the change's logic
  lives; it is pure and testable without a ViewModel, Firebase, or async.
- **Modified** `Features/Medal/Medals/ViewModels/MedalsViewModel.swift` — gains
  `selectedFilter` state and thin computed properties delegating to the above.
- **Modified** `Features/Medal/Medals/Views/MedalsView.swift` — new title, passes the
  view model through to `MedalList`.
- **Deleted** `MedalGrid.swift`, `MedalGridSection.swift`, `MedalCard.swift`,
  `MedalStatsSection.swift`. All four are referenced only within the medals feature.
- **Tests** — `MedalStatsTests.swift` extended; a new `MedalsViewModelTests.swift`
  (none exists today) for filter selection and its interaction with grouping.
- `Localizable.xcstrings` — keys for `Your Collection`, `All`, the per-year medal count,
  `No time recorded`, and `PR`, with `zh-TW` translations.
- Unchanged: the Firestore schema, `Medal`, `RaceDistance` encoding, `MedalDetailView`,
  achievements, profile stats, and `MedalEmptyView`.
- Out of scope: the Personal Best carousel that v4.3 places above the filter chips.
  Deferred to a follow-on change on this ticket, which reads the same per-category
  record this change derives.
