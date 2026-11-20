## Context

Every upload goes through `StorageService.upload(image:to:)`, which encodes with
`UIImage.uploadData()` (`jpegData(compressionQuality: 0.8)`), sets the content type to
`image/jpeg`, and uploads the bytes. Encoding from a `UIImage` leaves out the picked file's
metadata.

Photos reach an upload by two paths:
- **Cropping:** profile photos, race logos, edition photos and medal faces go through
  `PhotoSlot`. `PhotoSlotViewModel.cropPickedPhoto` decodes the picked data with
  `UIImage(data:)`, or the camera hands over its photo, and CropImage's `CropImageView` crops it. With CropImage 1.1.0,
  medal faces come out at 840 × 840 (`outputSide: 840`), and the others at the crop region's
  size in points at scale 1: 302 px on an iPhone 17 Pro.
- **Event photos:** `EditMedalView` loads up to 10 picked items as `Data`, and
  `EditMedalViewModel.addEventPhotos` stages them on `DraftEventPhoto`. At save, each is
  decoded and uploaded through `StorageService` at full resolution.

CropImage 2.0.1 has no `outputSide`. Its crop is always the source pixels the crop region
covers, copied one to one, at scale 1. Zooming in covers fewer pixels and gives a smaller image.

`storage.rules` requires `image/jpeg` on every create and update, and checks no size. Uploads
under a race id with no document are open to any signed-in user, because Add Race uploads the
logo before it creates the race. When a rule refuses an upload, Storage returns the same
permission error whichever rule it was.

A 3840 × 2880 image of pure random noise encodes to 12.43 MB at quality 0.8, measured with
ImageIO's JPEG encoder on macOS, which `jpegData` uses.

## Goals / Non-Goals

**Goals:**
- Every stored photo keeps the pixels it was picked, taken or cropped with.
- Storage bounds what any one upload can store, from any client, at 10 MB.
- A user whose photo is over the limit learns it when they pick or crop it, before filling in
  the rest of the form.

**Non-Goals:**
- Shrinking, re-encoding or deleting files already in Storage.
- More than one stored size per photo, or thumbnails.
- Changing the JPEG quality or the camera flow.
- Showing progress while picked photos are checked.

## Decisions

### Photos keep their own pixels
`uploadData()` encodes the image at its own size. `cropPickedPhoto` reads the picked data with
`UIImage(data:)`, so the crop starts from every pixel of the photo, and CropImage 2.0.1 keeps
the pixels the cropped square covers. `PhotoSlot` has no `outputSide`, so every slot stores the
crop's own pixels: medal faces, profile photos, race logos and edition photos.

A web page, a share image or a later effect such as background removal can be made from the
stored photo at whatever size it needs. Android and web store what the user picked or cropped
in the same way, and only the 10 MB limit has to match across clients.

### One limit: 10 MB, measured on the JPEG
`UIImage.maxUploadByteCount` (10 × 1024 × 1024), next to `uploadData()`, is the app's copy of
the cap in `storage.rules`. A photo passes when its `uploadData()` is smaller. The size that
counts is the JPEG the app uploads, not the picked file: a HEIC file is roughly half the size
of the same photo as a JPEG.

`uploadData()` and the size check are `nonisolated`, so they run off the main actor. Encoding
a full-resolution photo takes a noticeable moment, and 10 picked at once would freeze the form.
`addEventPhotos` frees each photo's buffers before checking the next, so ten large photos are
never in memory together.

### Each photo is encoded once, when it is picked or cropped
- **Event photos:** `addEventPhotos` becomes `async`. It encodes each picked item off the main
  actor and checks the JPEG. An item that is not an image, or whose JPEG reaches the limit, is
  skipped. The others are staged on `DraftEventPhoto` as their checked JPEG. Once they are
  staged, it throws `.photoTooLarge` if any item was too large, and otherwise
  `.photoDataInvalid` if any was not an image. `EditMedalView` awaits it and presents the
  error through its `errorWrapper`.
- **Cropped photos:** when the crop is confirmed, `PhotoSlot` has its view model encode it off
  the main actor into a `CroppedPhoto`: the image the slot shows, and its checked JPEG. A photo
  at the limit reaches `onError(.photoTooLarge)` and the slot is unchanged. Any other reaches
  `onPick` as a `CroppedPhoto`, which the form stages in its `DraftPhoto`; an edition's then
  waits on `DraftRaceEdition.newPhoto` until the race saves. Each confirmed crop is numbered
  with `LoadSequence`, and only the newest one's photo is used, so a slow check that ends after
  a newer crop changes nothing.
- **Upload:** `PhotoStorage` and `UserManager.updateUser` take the checked JPEG, and
  `StorageService` uploads it as it is. It still refuses one at or over the limit, throwing
  `.photoTooLarge`, so a save fails with that error rather than with Storage's permission
  error. No save encodes a photo again, so the bytes uploaded are the bytes checked.

`checkedUploadData()`, `checkedUploadSize(_:)` and `CroppedPhoto(checking:)` throw only
`AppError`, so no caller maps any other error.

### Each form keeps its photo as a `DraftPhoto`
The profile, race and edition forms each keep one `DraftPhoto`, and the medal form one per
face: the `PhotoSlotContent` its slot shows (the photo, the stored photo loading or failed, or
empty), the `CroppedPhoto` save uploads, and whether the user changed it. `PhotoSlot` takes that
content as it is. A stored photo that downloads after the user cropped or removed one is not
shown, and a failed download keeps a photo already shown.

### Save waits for photo checks
Each edit form (profile, race, edition and medal) counts the checks in progress with
`PhotoChecks`, and its Save button follows `canSave`: a valid form with no check in
progress. `PhotoSlot` reports each check through `onCheckingChange`, and an event-photo pick
counts from loading the picked items to the end of their check. A photo is never left out of a
save, because Save cannot start before its check ends.

### "Photo Too Large"
`AppError.photoTooLarge`:

| | English | Traditional Chinese |
|---|---|---|
| Title | Photo Too Large | 照片過大 |
| Message | Photos must be under 10 MB. | 照片必須小於 10 MB。 |
| Guidance | Please choose a smaller photo. | 請選擇較小的照片。 |

### A 10 MB cap in `storage.rules`
`isJpeg()` becomes `isAllowedPhoto()`:
`request.resource.contentType == 'image/jpeg' && request.resource.size < 10 * 1024 * 1024`.
It replaces `isJpeg()` in every create and update rule, so every path that accepts a photo
gets the cap, including a logo under a race id with no document. The MW-25 comment is removed.
Rules see bytes, not pixels, so the byte size is what they check.

### Medal faces in the design system
The canvas says medals are saved as "840 × 840 JPEG" (`MedalImage.saved` in `tokens.json`).
`deviations.md` gains `component.MedalImage.saved`: the code stores the cropped square at the
photo's own pixels, because a stored photo can be made smaller later but never sharper. Status
`unreported`, ticket MW-25.

### CropImage from GitHub
MedalWall takes CropImage from GitHub, up to the next major version from 2.0.1.

## Risks / Trade-offs

- [Larger files] A face or logo is stored at the crop's own size, which can be several MB.
  The medal wall downloads the full file for every face it shows, and every user who browses
  races downloads each race's logo. → Accepted for the development stage. A smaller copy can
  be made later from the stored photo without asking users for it again.
- [Photos over the limit] A full-resolution photo from a high-resolution camera, or a loose
  crop of one, can encode at 10 MB or more and be refused. → The user learns it when picking or
  cropping, and can choose another photo or crop it more closely.
- [Memory while cropping] Cropping a 48 MP photo holds the decoded photo (about 190 MB) and its
  crop (up to about 146 MB) at once, and the form keeps both faces until save. → Checked on a
  device. Display elsewhere is unaffected: `CachedAsyncImage` decodes at display size.
- [A wait after picking] 10 large event photos take a moment to check before they appear, with
  no progress shown, and Save waits until they have. → The check runs off the main actor, so
  the form stays responsive.
- [A closely cropped medal has few pixels] Cropping a medal that is small in the photo gives a
  crop of a few hundred pixels, which looks soft. → It is never enlarged. The photo flow tells
  the user to keep everything else out of the shot, so the medal fills most of it.
- [Older builds after the deploy] A 1.1.0 build uploading a full-resolution event photo over
  10 MB fails to save it once the rules are deployed. → The app is not yet public. Once it is,
  a tighter cap ships only after the app version that respects it.
- [Files already stored] Existing files keep their size. Rules check only new writes, and a
  kept photo is never re-uploaded, so they are not refused.

## Migration Plan

1. Merge the app change and the rules together.
2. Deploy the rules with `cd rules-tests && npm run deploy`, after the rules tests pass and the
   user agrees.
3. Rollback: redeploy the previous `storage.rules` from git, and revert the app change.
