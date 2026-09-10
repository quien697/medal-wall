## Context

`MedalDetailView` builds a `MedalDetailViewModel` from one `Medal` in its `init` and hands
formatted strings to five section views. Its hero goes through the shared
`DetailHeroSection`, which `RaceDetailHeroSection` also uses. Its stats are a two-column
`LazyVGrid` of `MedalDetailStatsGridItem`, each a label over a value over an optional
subheadline, and the ViewModel fills absent values with `"-"` and `"--'-- \""`.

Three things around the screen have moved since it was written. MW-30's list redesign
replaced the row's `-` with `No time recorded` and established that an unrecorded result is
a state to state rather than a character to print. The personal best carousel derived
`personalRecords` over the collection and marks the holder with the champagne tag. And
`paceText` moved onto `DistanceUnit`, which now owns pace formatting alongside
`abbreviation()` and `formatted(kilometers:)`.

Design system v4.3 restructures the screen into four bands: identity, facts, the result,
the day — with tags after. The mockup shows a fully recorded medal, so what a sparse medal
looks like is a decision this change makes rather than reads off.

## Goals / Non-Goals

**Goals:**
- A screen whose weight matches what a medal is for: the result, stated large.
- A result grid that doubles as a prompt — it says what is unrecorded rather than hiding it.
- One uniform result cell, so five fields share one component instead of five layouts.
- Formatting decisions in the ViewModel, testable without a view.

**Non-Goals:**
- Deriving personal records on this screen.
- v4.3's navy "Hero surface" panel and its Share action; there is no Share feature.
- Any Firestore schema change, or any change to the record-derivation rules.
- Changing the photo viewer, the edit sheet, or the delete flow.
- Editing from the detail screen beyond the existing menu.

## Decisions

**1. The record set is passed in, and kept live rather than frozen.**

`MedalDetailView(medal:personalRecordIDs:)`. A personal record is a property of the
collection — MW-30's design states this as the reason it is never persisted — and this
screen is handed one medal. Both call sites already know the answer: `MedalYearSection`
and `MedalPersonalBestCarousel` both hold `personalRecordIDs` and pass it straight
through; `isPersonalRecord` is computed from it (`personalRecordIDs.contains(medal.id)`)
rather than resolved once at open.

The plan going in accepted a frozen `Bool` and its stale-flag cost (below) as "too much
machinery for a badge." In practice `personalRecordIDs: Set<String>` costs nothing extra
to carry — the call sites already hold it as a set, not a bool — and `reloadMedal()`
already had to re-fetch this medal after an edit; re-fetching the collection alongside it
closes the gap the plan had accepted:

```swift
func reloadMedal() async {
  async let updatedMedal = repository.fetchMedal(id: medal.id, userId: medal.userID)
  async let allMedals = repository.fetchMedals(userId: medal.userID)
  guard let updated = try? await updatedMedal else { return }

  medal = updated
  if let all = try? await allMedals {
    personalRecordIDs = all.personalRecordIDs
  }
}
```

*Superseded — accept a stale flag between edit and dismissal:* the plan going in expected
`isPersonalRecord` to be a frozen `Bool` that `reloadMedal()` couldn't refresh, since the
screen had no collection to refresh it from. Once `reloadMedal()` fetches the collection
anyway, holding the live set instead of a snapshot bool removes the staleness for free.

*Alternative — no marker on this screen:* the list and the carousel already mark the
record, but the detail is where a user reads the time itself, which is exactly where the
marker means most.

**2. Finish leads its own band; one cell shape covers the four placements.**

```swift
MedalDetailResultItem(
  label: String,      // "Overall", "Division (M30-34)"
  value: String,      // "1058", "4′59″", "—"
  suffix: String?,    // "/ 7373", "/KM", nil
)
```

Finish is not one of these cells. It renders first, on its own `surfaceStyle()` band above
the two-column grid, with the champagne `PR` marker beside it when `isPersonalRecord` is
set — the value the screen exists to give gets its own visual weight rather than sharing a
grid cell's shape with four other fields. The record flag therefore lives on
`MedalDetailResultSection`, not on `MedalDetailResultItem`, which turned out to need no
`isRecord` case at all.

The remaining four fields — average pace, overall, gender, division — are the same thing
once the pattern is visible: a large tabular value with a small secondary tail. `1058` +
`/ 7373`, `4′59″` + `/KM`, `523` + `/ 1633`.

This replaces `MedalDetailStatsGridItem`'s label/headline/subheadline, whose third line put
the total *under* the placement rather than beside it, and whose `headLineColor` parameter
existed to paint the finish time gold — which v4.3 forbids: finish times are ink, never
gold, because a time is a value rather than an award.

**3. Division is one fact, and its group lives in the label.**

Today the grid states `Division Group: M30-40` and `Division: 523 / 1633` as two cells, as
though the group were a separate measurement. It is the field the placement was run in, so
v4.3 folds it into the label: `DIVISION (M30-34)` over `523 / 1633`. This is also why the
label is a `String` rather than the `LocalizedStringKey` the old grid item took — it is
composed from a translated stem plus a division that is not translatable text.

A medal with no division keeps the cell under a plain `Division`, per the spec: the field
is a thing the user can still fill in.

**4. Every field renders; the ViewModel decides what unfilled looks like.**

The spec requires all five fields on every medal. The ViewModel returns the final string —
`—` for an unfilled pace, overall, gender or division, and `No time recorded` for an
unfilled finish — rather than an optional the view falls back on. That keeps
`MedalDetailResultItem` free of any decision, matches how `MedalDetailViewModel` already
returns its placeholder strings, and puts the wording somewhere a test can read it.

Suffixes stay optional, because a suffix without its value is worse than nothing: a cell
reading `— / 7373` would state a total for a placement that was never recorded.

The em dash is one glyph across four fields, replacing today's mismatched `-` and
`--'-- \"`. Finish keeps words because MW-30 already established that wording for an
untimed medal, and because it is the one field large enough to carry them.

**5. Pace splits in `DistanceUnit`, not by taking the string apart.**

The mockup renders `4′59″` large with `/KM` small, but `paceText(minutesPerKilometer:)`
returns them joined. Splitting the result on `" /"` would make the layout depend on the
format string's punctuation. `DistanceUnit` gains `paceValueText(minutesPerKilometer:)`
returning the value alone, and `paceText` composes it with `abbreviation()` — so the two
callers agree by construction and the format is written once.

`paceValueText` returns `String?`, `nil` when there is no pace, rather than an unfilled
marker. The em dash is this screen's wording for an unfilled field, not a fact about
units, so `DistanceUnit` does not learn it. `paceText` keeps its own `--'-- "` placeholder
ahead of the composition, leaving its existing contract — which `MedalDetailViewModelTests`
already pins — untouched.

**6. The hero stops using `DetailHeroSection` — and that component is deleted.**

That component laid out a photo beside leading-aligned info; v4.3 centres the medal above
centred display type. Rather than add a mode to a shared component for one caller,
`MedalDetailHeroSection` lays itself out. The plan going in was to leave `DetailHeroSection`
in place for `RaceDetailHeroSection`; in practice `RaceDetailHeroSection` had already built
its own inline `HStack` layout rather than going through the shared component, so once this
screen stopped calling it, it had no caller left anywhere in the app and was deleted rather
than kept as unused code.

**7. The day is one band.**

`MedalDetailEventPhotosSection` and `MedalDetailNoteSection` currently appear and disappear
independently, so a medal with a note and no photos shows a lone `Notes` heading. v4.3
groups both under `The day`, which also states what the band is *for* — what the user
captured — rather than naming two data types.

**8. Mockup drift resolved toward the token list, as MW-30 Decision 8 did.**

- Section headers are `14/800 +0.16em` upper in the mockup's `#636A77`. They take
  `PageSection`, whose `sectionTitleStyle()` is `sectionTitle` at `Text.tertiary`.
  Hand-rolling them at `Text.secondary` would match the mockup more closely and make this
  the one screen whose headers differ from Profile and RaceDetail. Consistency wins;
  changing `sectionTitleStyle()` itself is a design-system decision, not this change's.
- Result values are `26/800` in the mockup. `Font.TypeScale.Numeric.large` (32, bold,
  monospaced) is the numeric top of the scale and takes them, keeping placements column
  aligned across the grid.
- Fact rows are `9px/700` labels against `13px/700` values; §02 bottoms out at `microLabel`
  (10/700), which takes the labels, and `caption` (13/500) takes the values.
- The race name is `Font.TypeScale.title1`, set at its natural case rather than the
  mockup's `26/900` uppercase — a deliberate divergence from v4.3, carried until the design
  system itself is updated.
- Tags are `.chipStyle(.neutral)` capsules. The mockup draws them white with a border,
  which is what that chip style already is.

**9. `PageSection` gains `alignment` and `spacing`, in place of a non-goal.**

The plan going in treated `PageSection` as unchanged: every existing section was fine with
its hardcoded leading alignment and `VStack`'s default spacing. In practice
`MedalDetailResultSection` needed the finish band pulled closer to the grid than that
default allows, and `MedalDetailInfoSection` needed zero spacing between its
hairline-separated rows. Rather than reach around `PageSection` with local padding tricks,
it gained `alignment: HorizontalAlignment = .leading` and `spacing: CGFloat? = nil`
parameters — both default to exactly today's behaviour, so every other caller is
unaffected.

## Risks / Trade-offs

- **A stale record marker after an in-place edit** → Superseded (Decision 1): once
  `reloadMedal()` fetches the collection to refresh `personalRecordIDs`, the marker is
  live rather than a snapshot, so there is nothing left to accept here.
- **Five always-present cells make a bare medal look empty** → Intended. The spec makes it
  a requirement rather than an accident: the grid is also a prompt.
- **`Numeric.large` at 32pt in a two-column grid may crowd a four-digit placement beside a
  four-digit total** → The value and suffix are different sizes, so the pair is narrower
  than it looks; to be checked on device against a `1058 / 7373` medal, which the sample
  data carries.
- **Renaming two files** → Contained; both are referenced only by `MedalDetailView`.
- **`MedalDetailView` gains a required init parameter** → Both call sites are in this repo
  and are updated here; the compiler finds any that are missed.

## Migration Plan

No data migration — nothing persisted changes. Rollback is a branch revert. The change is
additive except for two renames, the deletion of `DetailHeroSection` (found to have no
caller left once this screen stopped using it), and widening `PageSection` with two
optional parameters. The last two reach outside the medal detail feature into
`Shared/Components/Section`, but are non-breaking for every other caller.

`medal-detail` is a new capability, so its spec has no prior version to fold onto. It
archives independently of `medal-browsing`, which MW-30's other two changes share.

## Open Questions

None blocking. Deliberately deferred:
- Whether the facts list should also become the shape `RaceDetailView` uses; it is the same
  pattern, but that screen is not part of this change.
- Whether an unfilled result cell should be tappable, opening the edit sheet at that field.
  It would make the prompt actionable, and it is a larger interaction than a redesign.
