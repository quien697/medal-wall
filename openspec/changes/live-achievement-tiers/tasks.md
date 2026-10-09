## 1. Live tier

- [ ] 1.1 Failing test: `AchievementProgress.compute(liveCount:)` takes the tier from the live count alone (e.g. 4 medals is Hat Trick, whatever was reached before); update the existing `compute` tests to the new signature and remove the `ratchetedMilestone` tests
- [ ] 1.2 `compute(liveCount:)` derives the tier from the live count; remove `ratchetedMilestone`; update `ProfileViewModel` (`fullMarathonProgress` / `halfMarathonProgress` without a `User`), `ProfileView` and the previews

## 2. Remove the stored milestones

- [ ] 2.1 Remove `refreshAchievementMilestones` and its `UserManagerTests`; remove the post-save fetch and the `userManager` parameter from `EditMedalViewModel.save`, updating `EditMedalView` and `EditMedalViewModelStorageTests`
- [ ] 2.2 Remove `highestFullMilestone` / `highestHalfMilestone` from `User`, `userUpdateFields` and the `UserFirestoreRepositoryTests` fixtures

## 3. Verify

- [ ] 3.1 Full test suite passes with no new SwiftLint warnings
- [ ] 3.2 Manual check: on a profile whose stored milestone is above its live count, the Profile shows the live tier; adding and deleting a full-marathon medal moves the badge both ways; editing the profile leaves the old fields in the Firestore document untouched

## 4. Archive

- [ ] 4.1 On archive, also rewrite the `achievements` Purpose (no longer "sticky") and its "Display uses `max(persisted, live)`" design note, which the delta cannot reach
