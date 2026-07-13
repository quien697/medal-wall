## 1. Verify races spec against code

- [x] 1.1 Confirm Race CRUD matches `RaceFirestoreRepository` (create/read/update/delete)
- [x] 1.2 Confirm RaceEdition CRUD matches `RaceFirestoreRepository` editions methods
- [x] 1.3 Confirm cascade-delete-editions behavior matches `deleteRace()`
- [x] 1.4 Confirm one-day edition display matches `RaceEdition.isOneDay`/`dateDisplayLabel`

## 2. Verify medals spec against code

- [x] 2.1 Confirm Medal CRUD matches `MedalFirestoreRepository` (create/read/update/delete)
- [x] 2.2 Confirm medals are scoped to `userID` / stored under `users/{uid}/medals`
- [x] 2.3 Confirm `EventPhoto` array is distinct from the medal's single cover photo

## 3. Verify profile spec against code

- [x] 3.1 Confirm editable fields match `User` model (firstName, lastName, photoUrl, bio, gender, birthday)
- [x] 3.2 Confirm "Runner" fallback matches `UserName.fullName`
- [x] 3.3 Confirm computed stats match `Medal+Stats.swift` (fullCount, halfCount, bestFullTime, bestHalfTime)

## 4. Verify settings spec against code

- [x] 4.1 Confirm appearance picker matches `AppearancePicker` + `@AppStorage("appTheme")`
- [x] 4.2 Confirm no other settings (export/units/notifications/sync) exist in `SettingsView` today

## 5. Verify auth spec against code

- [x] 5.1 Confirm email-link, Google, and Apple sign-in match `AuthService` methods
- [x] 5.2 Confirm session validation (`validateSession()`) signs out locally on `userNotFound`
- [x] 5.3 Confirm sign-out is exposed from `SettingsView`

## 6. Finalize baseline

- [x] 6.1 Run `openspec validate baseline-current-capabilities` and resolve any errors
- [x] 6.2 Archive the change so specs land in `openspec/specs/`
