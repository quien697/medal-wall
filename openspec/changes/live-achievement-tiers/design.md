## Context

Achievements (2026-07-14) show two tracks, Full and Half Marathon, each with a tier from a
shared list (1, 3, 5, 10, 25, 50, 100). Today a tier is "sticky":

- `User.highestFullMilestone` / `highestHalfMilestone` hold the highest threshold reached.
- After every medal create or edit, `EditMedalViewModel.save` fetches all medals and calls
  `UserManager.refreshAchievementMilestones`, which ratchets the stored values up with
  `AchievementProgress.ratchetedMilestone` and writes the whole `User` back.
- `ProfileViewModel` passes the stored value and the live count to
  `AchievementProgress.compute`, which shows the higher of the two.

The live counts (`fullCount`, `halfCount`) are already computed on the Profile for its
statistics. The stored values exist only to keep a tier after its medals are deleted.

## Goals / Non-Goals

**Goals:**
- A track's tier and progress come from the medals the user holds now.
- Nothing about achievements is stored or written.
- Close review finding #11 by removing the value it could lower.

**Non-Goals:**
- Removing the old fields from existing Firestore documents.
- Any other achievement change: tiers, badge art and quiet unlocking stay as they are.

## Decisions

### Derive the tier from the live count

`AchievementProgress.compute(liveCount:)` clamps the count to `0...` and takes the unlocked
and next tier from it. `ProfileViewModel` exposes `fullMarathonProgress` and
`halfMarathonProgress` as computed properties over the loaded medals, so they no longer need a
`User`. `progressFraction` keeps its `0...1` clamp: it is the guard from `1d16f27` and costs
nothing, though with live counts the count can no longer sit below the unlocked tier.

- *Alternative: keep the stored milestone as a display floor but stop writing it.* Old values
  would still hold some badges up, differently on each account, with no way to lower them.

### Remove the write path entirely

`refreshAchievementMilestones`, `ratchetedMilestone`, the post-save medal fetch, and the
`userManager` parameter of `EditMedalViewModel.save` all go. The user document then has one
writer, the profile save, so #11's stale-copy problem has nothing left to lower: profile fields
already follow "last save wins" by spec.

### Leave stored values where they are

Removing the two properties from `User` and from `userUpdateFields` means the app neither reads
nor writes them. `Codable` ignores the extra keys on decode, and `updateUser` leaves unlisted
fields untouched (`partial-document-updates`). Deleting them would need a one-off migration or
a delete on every profile save, for data nothing reads.

## Risks / Trade-offs

- [A user who deleted medals sees a lower badge after updating] → Intended: the badge now
  matches the collection. Users who never deleted medals see no change, since their stored and
  live tiers already agree.
- [Old milestone fields linger in Firestore] → Unread and harmless; a future client must not
  treat them as current. Noted in the `achievements` removal's Migration.

## Migration Plan

No data migration. Rolling back restores the fields and the ratchet; values written before this
change are still in the documents, and the ratchet catches up on the next medal save.
