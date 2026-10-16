## 1. Photo storage

- [x] 1.1 `PhotoStorage.deletePhoto(url:)` replaces the five path-based deletes; `StorageService` resolves it with `reference(for: URL)`; uploads go to unique paths; `maxUploadRetryTime = 30`. Update `deleteLogos(of:editions:)`, `MedalDetailViewModel.deleteMedal`, the existing removal clean-up, and `StubPhotoStorage` (records deleted URLs). Existing tests updated to assert URLs; full suite green
- [x] 1.2 Failing tests: `PhotoOwner.owns(path:)` accepts each owner's folders and old fixed file, and rejects another user's, another record's, and a race's editions' paths; each delete call passes its record as owner. Then `deletePhoto(url:ownedBy:)` refuses a resolved path its owner does not own

## 2. Replace and failed-save clean-up (TDD)

- [x] 2.1 Medal — failing tests: a replaced cover's old URL is deleted after the save; not deleted when the save fails; a cover and new event photos uploaded for a failed save (add and edit) are deleted. Then implement in `EditMedalViewModel`
- [x] 2.2 Race and editions — failing tests: a replaced race or edition logo's old URL is deleted after the save; a logo uploaded for a failed race, edition create or edition update is deleted. Then implement in `EditRaceViewModel`
- [x] 2.3 Profile — failing tests: a replaced avatar's old URL is deleted after the save; an avatar uploaded for a failed save is deleted. Then implement in `UserManager.updateUser`

## 3. Edit sheets

- [x] 3.1 Failing tests: saving offline in `EditMedalViewModel`, `EditRaceViewModel` and `EditProfileViewModel` reports `noInternetConnection` with no upload and no write. Then inject `NetworkMonitor` and check at the top of `save`
- [x] 3.2 Views: `.interactiveDismissDisabled()` on `EditMedalView`, `EditRaceView`, `EditRaceEditionView`, `EditProfileView`; spinner and disabled Cancel while saving on `EditRaceView` and `EditProfileView`; `EditMedalView` and `EditProfileView` show a thrown `AppError` as itself

## 4. Verify

- [x] 4.1 Full test suite passes with no new SwiftLint warnings
- [x] 4.2 Manual check: swipe down does nothing on the four form sheets and still closes a picker; saving in airplane mode shows "No internet connection" and keeps the edits; replacing a medal cover, race logo and avatar leaves only the new file in the Storage console
