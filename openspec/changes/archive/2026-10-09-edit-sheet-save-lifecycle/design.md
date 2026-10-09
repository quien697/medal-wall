## Context

Writes resolve only once the Firestore server accepts them (`persistence-integrity`), so a save
started offline waits until the connection returns. The three sheets that save to the server
react to that differently: Edit Medal disables Cancel and swipe while saving, so it cannot be
left; Edit Race and Edit Profile allow both, so a running save can be abandoned unseen. Edit
Race Edition only stages its edits for the race's save.

Storage paths are fixed per record — `users/{uid}/medals/{medalId}/medal.jpg`,
`users/{uid}/avatar/profile.jpg`, `races/{raceId}/logo.jpg`,
`races/{raceId}/editions/{editionId}/logo.jpg` — and the upload happens before the Firestore
write. A replacement therefore overwrites the file the record still points at. Event photos
already get a fresh `photoId` per new photo, so they are never overwritten. Deletes are
addressed by the same fixed paths.

## Goals / Non-Goals

**Goals:**
- No edit is lost to an accidental swipe.
- A save always ends in a visible success or failure, the same way on every sheet.
- An offline save is refused up front instead of hanging.
- A failed save never costs a photo the record still shows, and leaves no new file behind.

**Non-Goals:**
- Delete flows (medal, race) while offline. They have no saving state today and are left as
  they are.
- A "discard changes?" confirmation on Cancel. Cancel stays an explicit, immediate discard.
- Cleaning up photos already orphaned in Storage by earlier failures.
- Test coverage for the medal create path and field mapping (review item #5), which is a
  separate, test-only change.

## Decisions

### Check the connection before saving, don't time out the write
Each saving ViewModel takes an injected `NetworkMonitor` (default `NWPathNetworkMonitor()`, as
`UserManager` and `LoginViewModel` do) and, at the top of `save`, refuses with
`AppError.noInternetConnection` when `isConnected()` is false.

*Alternative — time out the Firestore write:* rejected. A timeout stops the app waiting, not
the write: Firestore keeps the queued write and sends it on reconnect, so the user would see
"save failed" for a save that later lands. A retry after a timed-out edition create would add
the edition count twice. *Alternative — allow Cancel during a save:* rejected; the result would
be lost unseen.

A connection lost *after* the check still waits for the server. That window is narrow and
resolves itself on reconnect.

### Shorten the upload retry time, not the write
`StorageService` sets `maxUploadRetryTime = 30` on its `Storage` instance (default 600 s).
Unlike a write timeout, a Storage upload that gives up has actually stopped, so the failure is
truthful. Other operations keep their 120 s default.

### Unique upload paths; delete by URL
Uploads append a UUID file name: `users/{uid}/medals/{medalId}/cover/{uuid}.jpg`,
`users/{uid}/avatar/{uuid}.jpg`, `races/{raceId}/raceLogo/{uuid}.jpg`,
`races/{raceId}/editions/{editionId}/editionLogo/{uuid}.jpg`. Event photo paths are unchanged. The
upload signatures stay the same.

A single `PhotoStorage.deletePhoto(url:)` replaces `deleteUserAvatar`, `deleteMedalPhoto`,
`deleteRaceLogo`, `deleteRaceEditionLogo` and `deleteMedalEventPhoto`. A record already holds
each photo's download URL, which is the only reliable address once names are unique, and it
also deletes photos stored at the old fixed paths — so no migration. It resolves the URL with
`Storage.reference(for: URL)`, which throws on a malformed or foreign-bucket URL;
`reference(forURL: String)` calls `fatalError` instead, and photo URLs come from Firestore
documents other clients may write.

*Alternative — keep fixed paths and upload to a temp path, then move:* Storage has no move;
it would be a copy plus two deletes.

### Delete only within the record's folders
Deleting by URL lets a record aim a delete anywhere: a race whose `photoUrl` was edited to
point at someone's avatar would get it deleted by whoever next replaces or deletes the race.
So `deletePhoto(url:ownedBy:)` takes a `PhotoOwner` (`user`, `race`, `edition`, `medal`) and
refuses a path outside that owner's folders, including each one's pre-change fixed file. A
race owns `raceLogo/` and its old `logo.jpg` but not its editions' folders. The path checked is
the one Storage itself resolves from the URL (`StorageReference.fullPath`).

This is a second line behind Storage rules, not a replacement: `Race.id` is read from a
document field, so a tampered race document can still name another race's folder.

### One clean-up rule in each ViewModel
After the write succeeds: delete every old URL the record no longer holds (removed or
replaced). If the write fails: delete every URL uploaded for this save. Both use `try?`, as the
existing removal clean-up does. This replaces the "removed photo" checks with a comparison of
old and new URLs.

For editions, an edition whose write fails keeps its `newPhotoData`, so a retry uploads again
to a new path; deleting the failed attempt's upload keeps that from accumulating files.

### Sheet behaviour in the view
`.interactiveDismissDisabled()` with no condition on the four form sheets. Edit Race and Edit
Profile adopt Edit Medal's pattern: `ProgressView` in place of Save and Cancel disabled while
`isLoading`. Edit Medal and Edit Profile currently map every failure to a generic save error;
they show a thrown `AppError` as itself, so "No internet connection" reads as such.

## Risks / Trade-offs

- [Storage security rules, not yet written, could be written for the old fixed paths] → the
  rules are to be added before release; they must allow the new `cover/`, `avatar/`,
  `raceLogo/` and `editionLogo/` paths.
- [Swipe never closes a form, even untouched] → Cancel is always in the same place; picker
  sheets keep swipe.
- [The 30 s limit could give up on a connection that is only briefly flaky] → it bounds how
  long Storage keeps retrying after a failure, and photos are JPEG-compressed (`uploadData()`,
  quality 0.8) before upload; the user can save again.
