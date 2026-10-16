## Why

The MW-32 review fixes changed what the edit sheets save and how long a save can wait on
Storage, but no spec says so. `development-workflow.md` treats an undocumented behavior change as
a spec gap, and the gap matters here: web, admin and Android clients are planned against the
same Firestore data, and they need the trimming rules written down to save text the same way.

## What Changes

Specs only; the code shipped in 9025209, ed48388, 614f0a1, 811d252 and 6215a8a.

- Edit Medal, Edit Race and Edit Profile save typed text without surrounding whitespace or line
  breaks. A blank optional note, website or bio is saved as none. A blank or repeated tag is
  not added. Save stays unavailable while a medal's or race's name is blank or its place lacks
  a country or a city.
- Every Storage call a save makes — uploading a photo, fetching its link, deleting a photo —
  gives up within 30 seconds, not only the upload.

## Capabilities

### New Capabilities

### Modified Capabilities
- `edit-sheets`: adds the trimming rules for entered text, and extends the 30-second limit from
  photo uploads to every Storage call made while saving.

## Impact

- No code changes. The behavior lives in `EditMedalViewModel`, `EditRaceViewModel`,
  `EditProfileViewModel`, `UserName`, `Place.isValid`, `EditMedalTagsSection` and
  `StorageService`, and is covered by their existing tests.
