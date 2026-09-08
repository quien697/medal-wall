## Context

MW-30 built the record derivation this change renders. `Medal+Stats.swift` holds
`personalRecords: [RaceDistanceCategory: Medal]` — the fastest eligible medal at each
distance, keyed by a category normalized through `RaceDistanceCategory(value:)` — and
`personalRecordIDs: Set<String>` derived from it so `MedalRow` can ask "does this medal
hold a record" in constant time. MW-30's design.md Decision 2 states the reason the
dictionary is the primitive: it answers "what is the record at each distance", which is
"the question MW-31's carousel asks, one card per entry". That is the whole of this
change's data layer; nothing about how a record is decided moves.

What the dictionary cannot do is drive a `ForEach`. It is unordered, and its keys are not
`Identifiable`. The carousel needs a stable sequence with stable identity, which is the
one thing this change adds below the view layer.

`MedalsView` reloads `medals` whenever `AddMedalView` or a pushed `MedalDetailView`
dismisses, so the carousel's contents can change under the user — including a card
appearing where none was, or the record at a distance changing hands. Identity has to
survive that.

Design system v4.3 is the visual source. It draws a single card above the filter chips;
the carousel behaviour around it — full width, snapping, and how a user learns there is
more than one card — was settled in brainstorming rather than read off the mockup.

## Goals / Non-Goals

**Goals:**
- Answer "what is my best at this distance" without scrolling, for every distance the
  user has one.
- Reuse MW-30's record definition literally — one rule, stated once, in one place.
- Keep the carousel a readout of the collection, not a second control over the list.
- Card content testable as plain arrays, like the rest of `Medal+Stats.swift`.

**Non-Goals:**
- Any change to what counts as a record, how ties break, or which times are eligible.
- Making the carousel filter the list, or the filter narrow the carousel.
- Persisting the paged position across launches or reloads.
- Records that are not finish times — placement, streaks, total distance.
- A Firestore schema change, a query predicate, or server-side ordering.

## Decisions

**1. `personalBests` is an ordered projection of `personalRecords`, not a second
derivation.**

```swift
extension Array where Element == Medal {
  var personalBests: [MedalPersonalBest] {
    let records = personalRecords
    return distanceCategoriesOwned.compactMap { category in
      records[category].map { MedalPersonalBest(category: category, medal: $0) }
    }
  }
}
```

Walking `distanceCategoriesOwned` rather than sorting the dictionary's keys buys the
ordering for free and guarantees it matches the filter chips — the two orderings can never
drift, because there is only one of them. `compactMap` drops a distance whose medals are
all untimed, which is the spec's "contributes no entry" without a branch to state it.

Both sides key on a category built by `RaceDistanceCategory(value:)`, so the dictionary
lookup hits: `personalRecords` normalizes before inserting and `distanceCategoriesOwned`
normalizes before returning. This is MW-30 Decision 4 continuing to pay off; a
`.custom(42.195)` medal lands on the same `.full` card as everything else.

*Alternative — sort `personalRecords.keys` by `value` descending:* one fewer property
read, but it restates the ordering rule that `distanceCategoriesOwned` already owns, and
the two would have to be kept in agreement by hand.

**2. `MedalPersonalBest` is identified by its distance, not by its medal.**

```swift
struct MedalPersonalBest: Identifiable {
  let category: RaceDistanceCategory
  let medal: Medal
  var id: Double { category.value }
}
```

The same shape and the same trick as `MedalYearGroup`, whose `id` is its year. Identity
has to be the distance because the medal is the part that changes: when a faster marathon
is added, the full marathon card must update in place rather than be torn down and
re-inserted, which is what identifying by `medal.id` would do — and with paging that reads
as the carousel jumping to a different card while the user is looking at it.

*Alternative — `Identifiable` by `medal.id`:* correct as identity, wrong as *page*
identity, for exactly the reason above.

**3. The ViewModel exposes `personalBests` over the whole collection; the view maps it to
card content.**

`MedalsViewModel` gains `var personalBests: [MedalPersonalBest] { medals.personalBests }`
— reading `medals`, never `medals.filtered(by: selectedFilter)`. That single line is what
makes the spec's independence-from-the-filter requirement true, and it is the same reading
MW-30 Decision 7 made for `personalRecordIDs`.

The formatting — `formattedHMS`, the pace string, `category.description` — happens in
`MedalPersonalBestCarousel` as it builds each `MedalPersonalBestCard`, exactly as
`MedalYearSection` formats a `Medal` into a `MedalRow`'s strings today. `CLAUDE.md`'s "no
logic in views" rule is about derived *values*; a section view mapping its model onto its
row component's parameters is this feature's established shape, and diverging from it here
would mean two conventions in one folder.

*Alternative — the ViewModel exposes pre-formatted card content structs:* a stricter
reading of the same rule, and it would make `MedalYearSection` the odd one out.

**4. Pace is formatted by calling `MedalDetailViewModel.paceText` where it stands.**

The card needs `4'59" /km`, which exists as `MedalDetailViewModel.paceText(
minutesPerKilometer:in:defaults:)` — already `nonisolated static` precisely so it can be
called without an instance — over `Medal.averagePace`. Calling it from the medals feature
is a feature-to-feature reference and the weakest seam in this change.

The better address is `DistanceUnit`, which already owns `formatted(kilometers:)` and
`abbreviation(defaults:)` and is where a reader would look for pace formatting. That move
is deliberately not made here: it would edit `MedalDetailViewModel` and its tests for a
change that has no other business in that file. If a third caller ever appears, that is
the moment to move it, and the move is mechanical.

**5. The carousel is pinned above the filter bar, inside the existing `safeAreaInset`.**

`MedalList` already pins `MedalDistanceFilterBar` in `.safeAreaInset(edge: .top)`. The
carousel joins it in a `VStack` there, matching the mockup, where carousel and chips are
both outside the scrolling region.

The cost is real: roughly 145pt of permanently pinned chrome beneath the large navigation
title. It is accepted because a record the user has to scroll to find is the problem this
change exists to solve — putting the carousel inside the scroll would restore it in a
subtler form.

*Alternative — the carousel as the first item in the `LazyVStack`:* cheaper on screen and
it scrolls away with the content it summarizes, which is the whole objection.

**6. Full-width cards page by snapping; the page indicator is dots.**

Cards take `.containerRelativeFrame(.horizontal)`; the scroll view takes
`.contentMargins(.horizontal, .Space.gutter, for: .scrollContent)` so a card sits on the
gutter while still travelling edge to edge, plus `.scrollTargetLayout()` and
`.scrollTargetBehavior(.viewAligned)` for the snap.

A full-width card leaves no peek of the next one, so discoverability needs an indicator.
It is dots — `Color.Text.secondary`, dimmed for the pages that are not current — and the
row is absent entirely at one record.

*Alternative — a typographic indicator reading `FULL · HALF · 10K` with the current one
emphasized:* more informative and closer to the design system's voice, and rejected on
placement. It would sit one row above `MedalDistanceFilterBar`, which is also a horizontal
row of distance labels with one emphasized. Two such rows stacked — one a control, one not
— is a worse confusion than the one it solves. Dots are the right answer here *because*
they are content-free: they say "there are three of these" without restating distances the
chips below already list.

*Alternative — the page position in the card's own header, `FULL · 1/3`:* costs no
vertical space and cannot collide with anything, but `1/3` beside a distance reads as
cryptic where dots are immediately legible.

**7. A card pushes `MedalDetailView`, with its zoom source id prefixed.**

The card wraps a `NavigationLink` to `MedalDetailView(medal:)` with
`.navigationTransition(.zoom(sourceID:in:))`, mirroring `MedalYearSection`. The source id
is `"personalBest-\(medal.id)"` rather than `medal.id`, because the same medal's row is
very likely on screen below with `.matchedTransitionSource(id: medal.id, in: namespace)`
already declared — two sources for one id in one namespace is ambiguous, and the zoom has
no way to choose. Both views share `MedalList`'s existing `@Namespace`.

This is also why the spec requires that an entry reaches its medal even when the filter
hides that medal's row: the carousel is not filtered, so it can offer a medal the list is
not currently showing, and the navigation must not depend on the row existing.

**8. Mockup drift resolved toward the token list, as MW-30 Decision 8 did.**

- The record time is `34px/900` in the mockup; `Font.TypeScale.Numeric.large` (32, bold,
  monospaced digits) is the top of the numeric scale and takes it. Monospaced digits also
  keep the time steady as the user pages between cards.
- `PERSONAL BEST` is `14px/800 +0.16em` upper, which is `Font.TypeScale.sectionTitle` with
  `.tracking()` and `.textCase(.uppercase)` at the call site — `Font` carries neither.
- The distance label and the meta line are `9px/700` in the mockup; §02 bottoms out at
  `microLabel` (10/700), which takes them, as in `MedalRow`.
- The card is `.surfaceStyle()` — the 18pt radius, 16pt padding and border of
  `.Radius.surface`, which is what the mockup's card draws by hand.
- The mockup's distance label reads `Full marathon`. The card shows `Full` — the
  `category.description` every other surface in the app uses, which also resolves a custom
  distance against the unit preference for free.

**9. Recompute on read; no caching.** Inherited unchanged from MW-30 Decision 9. The
carousel adds one `compactMap` over a handful of categories on top of a derivation the
screen already runs.

## Risks / Trade-offs

- **Pinned chrome costs ~145pt above the list** → Accepted per Decision 5; the alternative
  reintroduces the problem the change solves. If it proves too heavy in use, moving the
  carousel into the `LazyVStack` is a one-line change with no effect on derivation.
- **`MedalsViewModel` referencing `MedalDetailViewModel.paceText`** → A real seam
  (Decision 4). Contained to one call site, and the fix, when a third caller justifies it,
  is a mechanical move to `DistanceUnit`.
- **Dots say how many records exist but not which distances** → Accepted; the card's own
  header names its distance, and the alternative that names all of them collides with the
  filter bar.
- **A card can navigate to a medal the filter is hiding** → Intended, and specified.
  The carousel describes the collection, not the current view of it.
- **Two `matchedTransitionSource` anchors could exist for one medal** → Prevented by the
  `personalBest-` prefix (Decision 7), which is the kind of thing that breaks silently, so
  it is stated in the spec's navigation scenarios rather than left to the view.
- **A record changing hands mid-session could move the user's page** → Prevented by
  identifying a card by its distance (Decision 2).

## Migration Plan

No data migration — nothing persisted changes and no existing view is deleted. The change
is additive: `MedalList` gains a view above the filter bar, `Medal+Stats.swift` gains one
property, `MedalsViewModel` gains one. Rollback is a branch revert.

`medal-browsing` does not yet exist under `openspec/specs/` — MW-30 introduces it and is
not archived. Both changes' deltas target it, and MW-30 must archive first so this delta
folds onto a spec that already defines what a personal record is.

## Open Questions

None blocking. Deliberately deferred:
- Whether the carousel should page automatically to the distance the filter selects. Ruled
  out for this change as it makes the carousel a second display of the filter; worth
  revisiting only if users read the two as one control.
- Whether a card should offer sharing the record directly, which v4.3's "Hero surface"
  panel hints at for the medal detail header rather than for this screen.
