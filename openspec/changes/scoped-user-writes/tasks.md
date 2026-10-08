## 1. Repository: profile save

- [ ] 1.1 Failing tests: the profile update's fields hold only `profileUpdateFields` (no milestones, `uid`, `email` or `createdAt`) and delete each cleared optional; a fully populated `User`'s keys are covered by `profileUpdateFields`, `milestoneFields` and `neverUpdatedFields`, which do not overlap
- [ ] 1.2 Add the three field lists and `updateProfile(_:)`; remove `updateUser(_:)` and `userUpdateFields`

## 2. Repository: milestone raise

- [ ] 2.1 Failing tests for `raisedMilestones(stored:proposed:)`: takes the higher value per track; a missing, non-integer or negative stored value reads as `0`; reports whether anything went up
- [ ] 2.2 Add `raisedMilestones(stored:proposed:)` and `raiseMilestones(uid:full:half:)` as a Firestore transaction that writes only the two milestone fields, only when one went up, and returns the resulting pair

## 3. UserManager

- [ ] 3.1 Update `StubUserRepository`: record profile updates and milestone raises separately; a raise keeps the higher of its stored and proposed values and returns them
- [ ] 3.2 Failing tests: a profile save calls `updateProfile` only; a milestone refresh from an older copy whose tier is below the stored value leaves the stored value and sets `currentUser` to it; a refresh that raises nothing calls nothing; a failed raise leaves `currentUser` unchanged
- [ ] 3.3 `updateUser(_:photo:)` calls `updateProfile`; `refreshAchievementMilestones` calls `raiseMilestones` and applies the returned pair to `currentUser`

## 4. Verify

- [ ] 4.1 Full test suite passes with no new SwiftLint warnings
- [ ] 4.2 Manual check: in the Firestore console raise a user's `highestFullMilestone` above what the app shows, then on the device (without relaunching) edit the profile and save a medal that crosses a lower tier; the stored value stays, and the app shows it after the medal save
