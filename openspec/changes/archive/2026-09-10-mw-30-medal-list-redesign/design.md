## Context

`MedalsViewModel` fetches every medal for the signed-in user and holds the array in
memory. `MedalGrid` renders it into a two-column `LazyVGrid` of `MedalCard`s, preceded by
`MedalStatsSection`'s three `StatCard`s. Nothing sorts: `MedalFirestoreRepository.fetchMedals`
maps a `getDocuments()` snapshot straight to `[Medal]`, so the visual order is Firestore's
document order. A grid of undated cells hid that; a list with year headers cannot.

Everything the new screen needs is already persisted on `Medal` — `date`, `distance.category`,
and the optional `finishTime`. No schema change is required, and none is wanted: Firestore is
multi-client by design (web and Android clients are planned), so a stored `isPR` flag would
have to be recomputed and rewritten by every client on every write that could move a record.
A personal record is a property of the *collection*, not of a medal, and belongs in derived
code.

Two precedents shape the approach. `RacesViewModel.filteredRaces` establishes that filtering
and sorting are in-memory computed properties over a fully-fetched array, which `CLAUDE.md`
states as a rule. And `Medal+Stats.swift` already holds `fullCount`, `halfCount`,
`bestFullTime` and `bestHalfTime` as `Array where Element == Medal` extensions — this change's
logic is the same kind of thing, at the same address.

Design system v4.3 is the visual source. Where its iOS mockup and the token list (§04)
disagree, the token list wins per `CLAUDE.md`, and they disagree in two places here.

## Goals / Non-Goals

**Goals:**
- A year-grouped, deterministically ordered list that reads as a running history.
- A distance filter that describes the collection it filters, so it can never offer a dead
  option or empty the list.
- One definition of "personal record" that the deferred personal best carousel can reuse
  without restructuring.
- Derivation logic testable as plain arrays — no ViewModel, no Firebase, no async.

**Non-Goals:**
- The Personal Best carousel above the filter chips (a follow-on change on this ticket).
- Any Firestore schema change, query predicate, or ordering pushed to the server.
- Persisting the filter selection across launches.
- Search, multi-select filtering, filtering by year, or filtering by race type.
- Changing `MedalDetailView`, achievements, or profile stats.

## Decisions

**1. Derivation lives in `Medal+Stats.swift` as array extensions; the ViewModel is thin.**

```swift
extension Array where Element == Medal {
  var sortedForDisplay: [Medal]                             // date desc, id as tiebreak
  var distanceCategoriesOwned: [RaceDistanceCategory]       // longest first
  func count(for filter: MedalDistanceFilter) -> Int
  func filtered(by filter: MedalDistanceFilter) -> [Medal]
  var groupedByYear: [MedalYearGroup]                       // year desc
  var personalRecords: [RaceDistanceCategory: Medal]        // the primitive
  var personalRecordIDs: Set<String>                        // derived from the above
}
```

`MedalsViewModel` keeps `medals`, adds `selectedFilter`, and exposes computed properties that
delegate. Every function above is pure, so `MedalStatsTests` covers the whole change's logic
with literal arrays.

*Alternative — everything as computed properties on `MedalsViewModel`:* mirrors
`RacesViewModel.filteredRaces` most literally, but grouping plus record resolution plus counts
is considerably more logic than a one-line `filter`, and testing array math would mean
constructing a ViewModel to do it.

*Alternative — a `MedalCollection` value type owning filter state and derived views:* the
cleanest boundary in the abstract and the wrong trade for one screen. It inserts a type between
model and ViewModel that nothing else needs. Rejected as premature abstraction.

**2. `personalRecords` is a dictionary; `personalRecordIDs` is the lookup.**

The dictionary `[RaceDistanceCategory: Medal]` is the primitive because it answers "what is the
record at each distance" — the question the personal best carousel asks, one card per entry.
`MedalRow` asks a different question, "does this medal hold a record", once per row, and
wants O(1); it gets `Set<String>` of medal IDs derived from the dictionary's values.
Deriving the set from the dictionary rather than computing both independently means one
definition of the rule.

*Alternative — a `isPersonalRecord` computed property on `Medal`:* impossible. A medal cannot
answer the question alone; it needs the collection.

**3. Record eligibility explicitly excludes non-positive finish times.**

`finishTime` is `TimeInterval?`, decoded from Firestore without validation. A stored `0` or a
negative value would be the minimum of any category and would silently claim the record. Per
`CLAUDE.md`'s guard convention, eligibility is `finishTime > 0`, not merely non-nil, and a test
covers it. Ties go to the earlier date so exactly one medal per category is ever marked —
without that rule two identical times both light up and the marker stops meaning "the one".

**4. Category identity is normalized before use as a dictionary key.**

`RaceDistanceCategory` synthesizes `Hashable` over its cases, so `.custom(42.195)` and `.full`
are different keys despite describing the same distance. `RaceDistance` already sidesteps this
by defining `==` and `hash` over `category.value` rather than the case. Grouping and record
resolution therefore normalize through `RaceDistanceCategory(value:)` before keying, collapsing
`.custom(42.195)` into `.full`. Medals decoded from Firestore are already normalized —
`RaceDistance.init(from:)` calls that initializer — so this only guards in-app construction and
sample data, but a silently split "Full" bucket would be an ugly bug to chase.

**5. `MedalDistanceFilter` is an enum; its options are derived, never enumerated.**

```swift
enum MedalDistanceFilter: Hashable, Identifiable {
  case all
  case category(RaceDistanceCategory)
}
```
Options come from `distanceCategoriesOwned`, sorted by `category.value` descending —
`RaceDistanceCategory` is not `Comparable` and does not need to become so for one sort. Chip
labels reuse `category.description`, which already resolves against the distance unit
preference, so a custom distance renders in the user's unit for free.

*Alternative — `RaceDistanceCategory.standardCases` as fixed chips:* matches the mockup's three
chips exactly and offers `Full 0` to someone who only runs 10Ks, while hiding their 10Ks behind
`All`. Rejected.

**6. A stale selection falls back to `All`.**

Deleting a medal or editing its distance in `MedalDetailView` can remove the selected category
from the collection, and `MedalsView` reloads on dismiss. Rather than reconcile on every reload,
the ViewModel's `selectedFilter` getter returns `.all` when its stored case names a category no
longer in `distanceCategoriesOwned`. Resolving on read keeps the invariant true no matter how
the collection changed, with no reload hook to forget.

**7. Records are derived from the whole collection, not the filtered set.**

Filtering to `Half` must not promote the fastest *visible* medal into a record. Since records
are per-category and a filter selects one category, both readings mark the same medal today —
but computing over the whole collection is the definition that stays correct if filtering ever
becomes multi-select or year-based.

**8. Mockup drift resolved toward the token list.**

Checked against `Medal Wall iOS v4.4.html`; the first two bullets were since resolved by the
mockup itself, the rest stand as written.

- The mockup sets row metadata at `9px/700/+0.16em` uppercase. §02 bottoms out at Micro label
  `10/12/700/+14%` upper, so those lines take `Font.TypeScale.microLabel`. Tracking and
  uppercasing are applied at the call site — `Font` cannot carry them.
  *Resolved in v4.4:* the mockup now draws this at `700 10px/1.2` with `1.4px` tracking —
  exactly `microLabel`. No longer a divergence.
- The mockup fills unselected chips `#EAE7DF`; the token list's `FilterChip .unselected` is
  white with an `#E4E1DA` border. Chips take `.chipStyle(.secondary)` selected-off and
  `.chipStyle(.primary)` selected-on.
  *Resolved in v4.4:* the mockup now draws the unselected chip `#FFFFFF` with a
  `1px solid #E4E1DA` border. No longer a divergence.
- The mockup's row name is `15px/700`, off-scale between `callout` (15/500) and `headline`
  (17/700). It takes `headline`, matching `MedalCard` today and keeping the race name the
  strongest line in the row.
- Finish times take `Font.TypeScale.Numeric.small`, which is already monospaced-digit, so
  times stay column-aligned down the list.
- The mockup draws un-ringed thumbnails on untimed medals. The ring stays unconditional per
  the product decision; `medalRing()` is applied by `MedalRow` exactly as `MedalCard` applies
  it today.

**9. Recompute on read; no caching.**

The computed chain re-runs whenever SwiftUI reads it. For a personal medal collection — tens
of medals, low hundreds at the outside — sorting and grouping is negligible, and caching would
add invalidation to maintain against a `medals` array that changes on every reload. If profiling
ever disagrees, the fix is local: cache in a `didSet` on `medals`.

## Risks / Trade-offs

- **A year-grouped list shows fewer medals per screen than a two-column grid** → Accepted, and
  the point of the change: the grid optimized for density, this optimizes for reading a career.
  The filter chips give back the fast path to a subset.
- **Recomputing derived properties on every `body` read** → Negligible at realistic collection
  sizes (Decision 9), with a local escape hatch if it ever isn't.
- **Deleting `MedalStatsSection` removes the only place `Total` was stated** → The `All` chip
  carries the same number, immediately above the list, and `ProfileSummarySection` still
  reports collection totals. `StatCard` itself is untouched.
- **Records are silently absent for a category where every medal is untimed** → Correct
  behaviour, not a failure: there is no record to show. The rows read `No time recorded`, which
  says why.
- **A `Set<String>` of record IDs assumes medal IDs are unique within a collection** → They are
  Firestore document IDs within one user's `medals` subcollection, so uniqueness is structural.

## Migration Plan

No data migration — nothing persisted changes. The four deleted view files are referenced only
within the medals feature, so removal is contained. Rollback is a branch revert.

## Open Questions

None blocking. Two deliberately deferred:
- Whether the filter should also offer race type (in-person / virtual / wheelchair). Not asked
  for; `RaceDistanceType` is shown on the row but not filtered by.
- Whether the selected filter should persist across launches. Currently resets to `All`, which
  matches the screen being a wall you walk up to rather than a workspace you return to.
