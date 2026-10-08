## 1. User

- [x] 1.1 Failing tests: `UserFirestoreRepository.updateFields(for:)` deletes each cleared optional, and its field list covers a fully populated `User`
- [x] 1.2 Add `userUpdateFields` and `updateFields(for:)`; `updateUser` writes with `updateData`

## 2. Medal

- [x] 2.1 Failing tests: `MedalFirestoreRepository.updateFields(for:)` deletes each cleared optional, and its field list covers a fully populated `Medal`
- [x] 2.2 Add `medalUpdateFields` and `updateFields(for:)`; `updateMedal` writes with `updateData`

## 3. Edition

- [x] 3.1 Failing tests: `RaceFirestoreRepository.updateFields(for:)` for a `RaceEdition` deletes a cleared photo, and its field list covers a fully populated `RaceEdition`
- [x] 3.2 Add `editionUpdateFields` and an `updateFields(for:)` overload for `RaceEdition`; `updateEdition` writes with `updateData`

## 4. Verify

- [x] 4.1 Full test suite passes with no new SwiftLint warnings
- [ ] 4.2 Manual check on a device or simulator: edit a profile, a medal and an edition, including clearing an optional value, and confirm in the Firestore console that an extra field added by hand survives and the cleared value is gone
