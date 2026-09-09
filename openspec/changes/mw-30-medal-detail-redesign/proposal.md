## Why

The medal detail screen predates the design system. Its hero stacks the race name over
place, date and bib as icon-labelled captions; its stats are six equal grid cells that
report a division group and a division placement as if they were separate facts; and a
medal with nothing recorded shows a wall of `-`. Design system v4.3 restructures it into
four bands — who and where, the result, the day, the tags — and gives the result the
weight the screen exists for. Tracked in Jira
[MW-30](https://quien.atlassian.net/browse/MW-30), the same ticket as the list redesign
and the personal best carousel.

## What Changes

- **BREAKING (display only):** the hero drops place, date and bib and becomes a centred
  88pt ringed medal beneath the race name at display size. The three facts it shed move
  into a list of their own.
- Add a facts list under the hero — Location, Date, Distance (with race type beneath the
  distance), Bib — as label-left value-right rows separated by hairlines.
- Rebuild the stats grid as **The result**: the finish time leads on its own band above the
  grid, then a two-column grid of average pace, overall, gender and division. Totals move
  inline beside their placement (`1058 / 7373`) rather than onto a second line.
- **Division collapses from two cells into one.** Today's `Division Group` (`M30-34`) and
  `Division` (`523 of 1633`) become a single cell whose label carries the group —
  `DIVISION (M30-34)` — and whose value is the placement. A medal with no division keeps
  the cell under a plain `DIVISION` label.
- Mark the finish time with the champagne `PR` tag when the medal holds its distance's
  record. The record is **passed in**, not derived here: a personal record is a property
  of the collection and this screen is handed one medal.
- **Every result cell always renders**, filled or not, so the grid also says what is
  still missing. An unrecorded pace, overall, gender or division reads `—`; an unrecorded
  finish keeps the `No time recorded` wording MW-30 established for rows.
- Group the event photos and the note under one **The day** header, rather than two
  sections that each appear and disappear independently.
- Tags become capsules. `CLAUDE.md` states hashtags are chips; they have been rendering
  as 6pt rect tags since the design system landed.
- Drop the inline navigation title. The hero states the race name at display size, so an
  inline title states it twice.
- No Firestore schema change. `Medal` gains no field, and no derivation rule changes.

## Capabilities

### New Capabilities
- `medal-detail`: how a single medal is presented on its own screen — which facts the
  screen states and in what order, that every result field is shown whether or not it is
  recorded, how an unrecorded field reads, how a division and its placement are stated as
  one fact, and where the record marker's truth comes from.

### Modified Capabilities
<!-- None. `medals` owns creating, reading, updating and deleting a Medal and the privacy
     scope of a fetch; none of those requirements change. `medal-browsing` owns the
     collection as a whole; this change alters nothing it specifies, and the record
     definition it introduced is reused untouched. -->

## Impact

- **Rewritten** `Features/Medal/MedalDetail/Views/MedalDetailHeroSection.swift` — stops
  using the shared `DetailHeroSection`, and sets the race name at its natural case rather
  than the mockup's uppercase, a deliberate divergence pending a design system update.
- **New** `MedalDetailInfoSection.swift` and `MedalDetailInfoRow.swift` (named `Facts` in
  the original proposal; renamed to `Info` during implementation).
- **New** `MedalDetailDaySection.swift`, composing the existing photo strip and note.
- **Renamed** `MedalDetailStatsSection.swift` → `MedalDetailResultSection.swift`, and
  `MedalDetailStatsGridItem.swift` → `MedalDetailResultItem.swift`, which gains an
  optional trailing suffix. The record flag ended up on `MedalDetailResultSection`
  instead: Finish renders on its own band rather than sharing the item's cell shape, so
  `MedalDetailResultItem` never needed `isRecord`.
- **Deleted** `Shared/Components/Section/DetailHeroSection.swift` — once
  `MedalDetailHeroSection` stopped calling it, it had no remaining caller;
  `RaceDetailHeroSection` had already built its own inline layout rather than going
  through it.
- **Modified** `Shared/Components/Section/PageSection.swift` — gains optional
  `alignment` and `spacing` parameters (both default to today's behaviour), so
  `MedalDetailResultSection` and `MedalDetailInfoSection` can ask for tighter spacing
  than the default without reaching around the component.
- **Modified** `MedalDetailTagsSection.swift` — `.chipStyle(.neutral)` in place of
  `.tagStyle(.neutralOnPage)`.
- **Modified** `MedalDetail/ViewModels/MedalDetailViewModel.swift` — takes
  `isPersonalRecord`, composes the division label, splits pace into value and unit, and
  returns `—` where it returns `-` today. Drops `distanceText`/`heroDistanceText`; the
  facts list now reads `medal.distance.displayLabel` directly, the same distance
  formatting every other screen already uses, rather than a hero-only format that
  appended the measurement to a preset (`Full · 42.2 km`).
- **Modified** `MedalDetailView.swift` — new composition, new init parameter, no inline
  title.
- **Modified** `Shared/UIModels/DistanceUnit.swift` — adds `paceValueText(
  minutesPerKilometer:)`; the existing `paceText` composes it with `abbreviation()` so the
  pace format stays written once.
- **Modified** call sites: `MedalYearSection` passes
  `personalRecordIDs.contains(medal.id)`; `MedalPersonalBestCarousel` passes `true`.
- **Tests** — `MedalDetailViewModelTests` extended; `DistanceUnitTests` extended for the
  split.
- `Localizable.xcstrings` — keys for `The result`, `The day`, `Location`, `Date`,
  `Distance`, `Bib`, `Finish`, `Avg pace`, `Overall`, `Gender`, `Division`, with `zh-TW`.
- Unchanged: the Firestore schema, `Medal`, the photo viewer, the edit sheet, the delete
  flow, `EditMedalView`, and every record-derivation rule.
- Out of scope: v4.3's "Hero surface · navy + Gilt Bright" panel and its Share action —
  a different treatment for a screen that has no Share feature to offer.
