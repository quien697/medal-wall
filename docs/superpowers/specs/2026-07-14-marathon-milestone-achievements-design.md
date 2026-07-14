# Marathon Milestone Achievements — Design

## 1. Context

`ProfileAchievementsSection` / `ProfileAchievementRow` currently render static
placeholder rows (a "Top 6" World Marathon Majors example) and aren't wired into
`ProfileView.body` at all. The vision doc (`2026-07-13-medalwall-vision-design.md`,
§6) flagged achievements as "undesigned until a dedicated brainstorming session
happens" — this doc is that session's output.

A full achievements system (Majors club, streaks, PBs) was considered but is
explicitly deferred (see §6). This design covers **one concrete achievement type**:
milestone counts for Full and Half Marathon completions.

## 2. Scope

- Two independent milestone tracks: **Full Marathon** and **Half Marathon**.
- 10K, 5K, and custom distances are **not** tracked by this feature.
- Both tracks share the same threshold/tier list (see §3) — full marathons are
  harder to accumulate than halves, but a shared list was chosen over per-track
  curves for simplicity; 100 (Centurion) is deliberately kept as a lifelong-goal
  cap for full marathons rather than removed or lowered.

## 3. Tiers

7 tiers, shared by both tracks:

| Threshold | Name |
|---|---|
| 1 | First Finish |
| 3 | Hat Trick |
| 5 | High Five |
| 10 | Perfect Ten |
| 25 | Quarter Century |
| 50 | Half Century |
| 100 | Centurion |

Represented as a new `AchievementTier` enum (`CaseIterable`, computed `name` +
`threshold`), following the same shape as `RaceDistanceCategory`.

## 4. Visual design

Badges follow the "evolving icon" direction (validated via visual companion
mockups): a single badge shape that becomes progressively more ornate/detailed
at each tier (more rings/detail layers), rather than color-coded gold/silver/bronze
— that color language is reserved for real race-placement medals
(`overallPlacement`, `divisionPlacement`, etc.) elsewhere in the app, and reusing
it here would blur the two concepts.

Layout per track (inspired by Pikmin Bloom's badge detail view): current badge +
tier name + progress toward the next tier, always visible inline — no separate
tap-to-expand detail sheet for v1 (the row already shows everything needed).

## 5. Data model

**New `User` fields:**
- `highestFullMilestone: Int` (default `0`)
- `highestHalfMilestone: Int` (default `0`)

These store the actual threshold value reached (0/1/3/5/10/25/50/100), not a
tier index — directly meaningful and matches the thresholds in §3.

**New `AchievementTier` enum** — ordered tier list with `name` and `threshold`,
used to look up "current tier" and "next tier" given a milestone value.

**New pure `AchievementProgress` computation** (extends the existing
`Medal+Stats.swift` pattern, e.g. `Medal+Achievements.swift`) — takes:
- `persistedMilestone: Int` (from `User`)
- `liveCount: Int` (from `[Medal]`, via the existing `fullCount`/`halfCount`)

Returns: the displayed unlocked tier, next tier (nil if maxed), and the live
count to show against the next tier's threshold. No new repository and no new
Firestore reads at Profile-load time — everything needed is already loaded.

### Displayed tier vs. persisted tier

The **displayed** unlocked tier is computed as `tier(for: max(persistedMilestone,
liveCount))`, not from `persistedMilestone` alone. In steady state these agree
(the ratchet in §6 keeps them in sync), but this guards against a transient case
— e.g. the ratchet write hasn't synced yet (offline) — where the user should
still see the correct badge immediately from live data. Only `persistedMilestone`
is what makes a tier sticky against later medal deletion; using `max()` for
display doesn't weaken that, since a temporarily-higher live count gets
ratcheted into the persisted value on the next successful write anyway.

**Progress toward the next tier always uses the raw live count**, not the max —
it's a truthful count of what's needed going forward, regardless of past
deletions.

## 6. The ratchet (ONE-way persistence)

After a medal create or edit succeeds (never on delete), recompute
`fullCount`/`halfCount` from the in-memory medals. If the live count now meets
or exceeds a threshold beyond the currently persisted value, write the new
(higher) value to `User` via `UserFirestoreRepository`. This is a strictly
monotonic, one-way ratchet — deleting medals afterward never lowers the
persisted value, so an earned badge is never taken away.

`UserManager` — already the single source of truth for the current `User` — is
the natural owner of this check, invoked from the medal save flow. The exact
call site (which ViewModel triggers it, whether it's a method on `UserManager`
or a small pure helper it calls) is a plan-level detail, not fixed here.

Unlocking is **quiet**: no toast, sheet, or notification at the moment of
crossing a threshold. The badge simply reflects the new state next time Profile
is viewed.

## 7. UI structure

`ProfileAchievementsSection` renders exactly 2 rows — Full Marathon and Half
Marathon — replacing the current 3 static placeholder rows, and gets wired into
`ProfileView.body` for the first time.

Each row shows: the evolving badge (via a new `AchievementBadgeView`, which owns
just the tier-to-shape rendering so `ProfileAchievementRow` doesn't have to),
the tier name, and progress text/bar toward the next tier (e.g. "7 of 25 →
Quarter Century"). When maxed (Centurion), no progress bar — just the
fully-ornamented badge and the tier name.

`ProfileViewModel` computes both `AchievementProgress` values from the medals
and user data it already loads, and exposes them to the view. No logic in the
view itself — it receives plain `AchievementProgress` values and renders them.

## 8. Edge cases

- **Zero medals in a category:** row still shows (both tracks always visible),
  badge in a dimmed "locked" state, progress "0 of 1 → First Finish."
- **Medal deleted below an earned tier's threshold:** badge stays at the
  persisted tier; progress bar toward the next tier reflects the new (lower)
  live count.
- **Live count exceeds persisted (pre-ratchet, e.g. offline):** displayed badge
  still reflects the higher live-derived tier (§5); persisted value catches up
  on the next successful write.
- **Fake/fraudulent medals** (e.g. someone else's photo, fabricated results):
  explicitly out of scope. The whole `Medal` model is already self-reported —
  bib number, finish time, and placement have no verification against an
  official results feed — so this isn't a gap unique to achievements.

## 9. Testing

Swift Testing, following the existing `MedalStatsTests.swift` /
`RaceDistanceCategoryTests.swift` patterns:

- `AchievementTier` ordering, threshold, and name lookups
- `AchievementProgress` computation: zero medals, exactly-at-threshold,
  between-thresholds, maxed at Centurion, persisted-higher-than-live
  (post-deletion), live-higher-than-persisted (pre-ratchet)
- Ratchet logic: only ever increases the persisted value, never decreases, and
  is a no-op when the live count hasn't crossed a new threshold

## 10. Deferred (future brainstorm)

- **Full achievement system**: Majors club (e.g. "6 World Marathon Majors"),
  streaks, personal-best achievements. Blocked on canonical race identity —
  races are currently freeform manual entries with no link to a known race
  registry, so an achievement like "ran all 6 Majors" can't be reliably detected
  yet.
- 10K/5K/custom distance milestone tracks.
- Any celebration/notification UI for unlocking a tier.
- Fraud/verification handling for medal data in general.
