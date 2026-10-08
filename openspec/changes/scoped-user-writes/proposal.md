## Why

Both writers of the user document — the profile save and the milestone refresh — send the
whole `User` this device holds, milestone counts included. That copy is read once per cold
launch and never refreshed while the app stays suspended, so a device holding an older profile
can write back a lower `highestFullMilestone` or `highestHalfMilestone` than another device
stored. That breaks the `achievements` promise that an earned tier is never lowered (review
finding #11, left out of `partial-document-updates` on purpose).

## What Changes

- A profile save writes only the profile fields — first name, last name, photo, bio, gender,
  birthday — and `updatedAt`. It no longer writes milestones, so it cannot lower them. The last
  save still wins for the profile fields themselves.
- A milestone refresh writes only the two milestone fields, inside a Firestore transaction that
  reads the stored values and keeps the higher of stored and new for each. A device's older copy
  can no longer lower a stored milestone, and the device takes back the stored values.
- **BREAKING (internal API)**: `UserRepository.updateUser(_:)` is replaced by
  `updateProfile(_:)` and `raiseMilestones(uid:full:half:)`.
- The user field-list guard test checks that every stored `User` field is written by exactly
  one of the two, or is declared never updated (`uid`, `email`, `createdAt`).

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `achievements`: the ratchet compares against the value stored on the server when it writes,
  not the device's copy.
- `profile`: a profile save writes only the profile fields; "last save wins" covers those
  fields, not milestones.
- `persistence-integrity`: a model written by more than one save lists the fields each save
  owns, and the guard test covers every field across them.

## Impact

- `MedalWall/Repositories/UserFirestoreRepository.swift` — the protocol and both writes.
- `MedalWall/Managers/UserManager.swift` — `updateUser(_:photo:)` and
  `refreshAchievementMilestones(medals:)`.
- `MedalWallTests/Support/StubUserRepository.swift`, `UserFirestoreRepositoryTests`,
  `UserManagerTests`.
- No Firestore schema change: same document and fields. A milestone raise now needs a
  connection, as a transaction fails offline instead of queueing; a failed raise is already
  ignored and the next medal save retries it.
- Out of scope: reloading the profile when the app returns to the foreground. Profile fields
  keep "last save wins" between devices.
