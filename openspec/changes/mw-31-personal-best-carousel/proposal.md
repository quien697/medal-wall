## Why

MW-30 derives a personal record for every distance the user owns and marks the holding
medal with a champagne `PR` tag, but the tag is only visible once you scroll to the year
that medal was earned. A runner opening their collection to answer "what is my marathon
best" has to hunt for it. Design system v4.3 answers the question at the top of the
screen, and MW-30 deliberately built `personalRecords` as a per-category dictionary so
this change could read it without restructuring anything. Tracked in Jira
[MW-31](https://quien.atlassian.net/browse/MW-31).

## What Changes

- Add a Personal Best carousel above the distance filter chips on the medals screen: one
  full-width card per distance category that has a record, paged with snapping, ordered
  longest distance first — the same order the filter chips already use.
- Each card states the record: `PERSONAL BEST` and the distance on a header row, the
  finish time as the card's headline, then the race name, the average pace, and the
  champagne `PR` tag.
- A card is tappable and pushes `MedalDetailView` for the record-holding medal, with the
  same zoom transition the list rows use.
- Show a page indicator beneath the carousel when — and only when — there is more than
  one record. A full-width card leaves no peek of the next one, so nothing else would say
  that more records exist.
- The carousel is **independent of the distance filter**. It always describes the whole
  collection; the chips below narrow only the list. Selecting `Half` does not reduce the
  carousel to one card, and paging the carousel does not change the filter.
- A distance whose medals are all untimed contributes no card, and a collection with no
  timed medals at all shows no carousel — not an empty state, simply nothing.
- **No new derivation rule.** What counts as a record, how ties break, and which finish
  times are eligible are all MW-30's definitions, reused unchanged. This change adds only
  an *ordered, identified projection* of them for the carousel to render.
- No Firestore schema change. `Medal` gains no field.

## Capabilities

### New Capabilities
<!-- None. The carousel presents the collection as a whole, which is exactly what
     `medal-browsing` already covers. -->

### Modified Capabilities
- `medal-browsing`: gains requirements for presenting the derived personal records
  directly — that every distance holding a record is presented, in longest-first order,
  that the presentation is independent of the distance filter, and that a record's
  presentation navigates to the medal holding it. The existing requirements defining what
  a personal record *is* are unchanged and are not restated here.

> `medal-browsing` is introduced by the un-archived MW-30 change and does not yet exist
> under `openspec/specs/`. Both deltas target it; MW-30 archives first, then this one.

## Impact

- **New** `Features/Medal/Models/MedalPersonalBest.swift` — an `Identifiable` pairing of a
  `RaceDistanceCategory` with the medal holding its record, identified by the distance so
  a card keeps its page position when a faster medal takes the record over.
- **New** `Features/Medal/Medals/Views/MedalPersonalBestCard.swift` and
  `MedalPersonalBestCarousel.swift`.
- **Modified** `Models/Medal/Medal+Stats.swift` — adds `personalBests`, the ordered
  projection of the existing `personalRecords` dictionary.
- **Modified** `Features/Medal/Medals/ViewModels/MedalsViewModel.swift` — adds a
  `personalBests` computed property and the formatted card content it renders from.
- **Modified** `Features/Medal/Medals/Views/MedalList.swift` — the carousel joins the
  filter bar in the existing top `safeAreaInset`.
- **Tests** — `MedalPersonalRecordTests` extended for the projection;
  `MedalsViewModelTests` extended for its independence from `selectedFilter`.
- `Localizable.xcstrings` — one new key, `Personal best`, with a `zh-TW` translation.
- Unchanged: the Firestore schema, `Medal`, `MedalRow` and its `PR` tag, the filter bar,
  the year grouping, and every record-derivation rule MW-30 established.
- Out of scope: making the carousel a control over the list, persisting the paged
  position across launches, and any record that is not a finish time (placement, streaks).
