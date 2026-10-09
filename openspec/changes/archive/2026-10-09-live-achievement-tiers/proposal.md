## Why

Milestone badges are "sticky": `User` stores the highest tier reached per track
(`highestFullMilestone`, `highestHalfMilestone`), `UserManager.refreshAchievementMilestones`
ratchets it up after each medal save, and the Profile shows `max(stored, live)` so deleting
medals never lowers a badge. That one choice costs a stored field pair, a second write path to
the user document, an extra medal fetch after every medal save, and review finding #11: a
device holding an older profile copy can write a lower milestone back. The 2026-07-14 design
states the rule but gives no reason for it, and medals are self-reported, so the common reason
to delete one — a duplicate or a mistake — is exactly when the badge should drop too.

## What Changes

- **BREAKING (behaviour)**: a track's tier comes from the live medal count alone. Deleting
  medals lowers the badge to match what the collection holds.
- `User` drops `highestFullMilestone` and `highestHalfMilestone`; the user update no longer
  lists them.
- `UserManager.refreshAchievementMilestones` and `AchievementProgress.ratchetedMilestone` are
  removed, and so is the medal fetch after a medal save that fed them. `EditMedalViewModel.save`
  no longer takes a `UserManager`.
- `AchievementProgress.compute` takes only the live count.
- Values already stored in Firestore are left in place and ignored: decoding skips unknown keys,
  and updates leave fields they do not list untouched.
- Supersedes `scoped-user-writes`, which is removed unimplemented.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `achievements`: "Sticky Milestone Persistence" is removed; "Displayed Tier and Progress"
  takes the tier from the live count.
- `profile`: the cached-profile and not-yet-loaded requirements no longer mention skipping
  milestone updates, since there are none.

## Impact

- `MedalWall/Models/User/User.swift`, `Models/Achievement/AchievementProgress.swift`,
  `Repositories/UserFirestoreRepository.swift`, `Managers/UserManager.swift`,
  `Features/Medal/EditMedal/ViewModels/EditMedalViewModel.swift` and `Views/EditMedalView.swift`,
  `Features/Profile/Profile/ViewModels/ProfileViewModel.swift`, and the previews in
  `ProfileAchievementsSection.swift` and `ProfileAchievementRow.swift`.
- Tests: `AchievementProgressTests`, `UserManagerTests`, `UserFirestoreRepositoryTests`, and any
  `ProfileViewModel` / `EditMedalViewModel` tests that pass milestones or a `UserManager`.
- Closes review finding #11: nothing stored can be lowered any more.
- No data migration. Old milestone fields stay in existing user documents, unread.
