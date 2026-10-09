## Why

The edit sheets for medals, races, editions and the profile handle the moments around a save
differently, and some of those moments lose work or photos:

- Swiping down closes a sheet mid-edit and silently discards what the user typed.
- Edit Race and Edit Profile can be closed while a save is running, so its result — success
  or failure — is never shown. Edit Profile shows no progress at all.
- Offline, Edit Medal is stuck on its spinner with Cancel and swipe disabled until the
  connection returns, because writes wait for the server by design.
- A replaced cover photo, race logo, edition logo or avatar is uploaded over the old file at
  the same Storage path *before* the Firestore write. If the write then fails, the old photo is
  already gone. A photo uploaded for a save that fails is left in Storage with nothing pointing
  at it.

## What Changes

- Swipe-to-dismiss is disabled on the four form sheets (Edit Medal, Edit Race, Edit Race
  Edition, Edit Profile). Cancel is the only way out. Picker sheets opened from a form keep it.
- Edit Medal, Edit Race and Edit Profile share one saving state: a spinner replaces Save and
  Cancel is disabled until the server answers. On success the sheet closes; on failure the
  error is shown and the edits stay.
- Those three saves check the connection first. Offline, the save is refused with "No internet
  connection" before anything is uploaded or written, and the sheet keeps the edits.
- Photo uploads give up after 60 seconds without a connection instead of Storage's default
  10 minutes.
- Every upload goes to a new, unique Storage path, so it never overwrites the file a record
  points at. A photo a record no longer holds — removed **or replaced** — is deleted by its URL
  only after the save succeeds. A photo uploaded for a save that fails is deleted.

## Capabilities

### New Capabilities
- `edit-sheets`: how a form sheet is closed, what it shows while saving, and how it refuses an
  offline save.

### Modified Capabilities
- `medals`: a replaced photo is deleted only after the save succeeds; a photo uploaded for a
  failed save is deleted.
- `races`: the same for race and edition logos.
- `profile`: the same for the profile photo.

## Impact

- `StorageService` / `PhotoStorage`: unique upload paths; one `deletePhoto(url:)` replaces the
  five path-based deletes; upload retry time set to 60 s. `StubPhotoStorage` records deleted
  URLs.
- `EditMedalViewModel`, `EditRaceViewModel`, `EditProfileViewModel` (and
  `UserManager.updateUser`): photo clean-up after replace and after a failed save; a
  `NetworkMonitor` dependency for the pre-save check.
- `MedalDetailViewModel`, `RaceDetailViewModel`, `RacesViewModel` (via `deleteLogos`): delete
  photos by URL.
- `EditMedalView`, `EditRaceView`, `EditRaceEditionView`, `EditProfileView`: swipe disabled,
  saving state, the offline error shown as itself.
- Firebase Storage security rules, not yet written, must allow the new paths when they are added
  before release.
- Existing photos at the old fixed paths need no migration: they are deleted by URL like any
  other.
