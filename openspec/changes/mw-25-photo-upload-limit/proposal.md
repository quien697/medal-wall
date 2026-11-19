## Why

Once the app is released, every photo stored in Firebase Storage is paid for, and nothing in
`storage.rules` bounds what one upload can store, from this app or from the Android and web
clients planned later. One limit in Storage holds for every client the same way. Cropped photos
are also stored small: medal faces at 840 × 840, and other crops at the crop region's size in
points, which look soft on large screens and in share images. A stored photo can be made smaller
later but never sharper, so the app keeps the pixels the user framed.

## What Changes

- `storage.rules` refuses any photo upload of 10 MB or more, at every path that accepts photos.
- The app refuses a photo whose JPEG is 10 MB or more with a new "Photo Too Large" error: an
  event photo when it is picked, a framed photo when its framing is confirmed, and any photo
  just before it is uploaded.
- Framed photos (profile photos, medal faces, race logos and edition logos) are stored at the
  photo's own pixels inside the framed square, through CropImage 2.0.1. Medal faces are no
  longer 840 × 840.
- Event photos are stored at the picked photo's own size. No photo is shrunk or enlarged.
- Every photo is stored as a JPEG at quality 0.8, with none of the picked file's metadata.

Out of scope: shrinking or deleting files already in Storage, storing more than one size of a
photo, and changing the JPEG quality.

## Capabilities

### New Capabilities
- `photo-uploads`: the resolution, format and size limit of every stored photo: photos kept at
  their own resolution, JPEG with no picked-file metadata, the Photo Too Large check, and the
  10 MB cap in Storage.

### Modified Capabilities
- `medal-photos`: the Stored Medal Photo requirement (840 × 840) is removed. Faces follow
  `photo-uploads`.

## Impact

- **Dependency:** CropImage 2.0.1, whose crop is always the photo's own pixels and which has no
  `outputSide`.
- **Photo slot:** `PhotoSlot` drops `outputSide`, and `EditMedalPhotosSection` stops passing
  840. After the framing is confirmed, `PhotoSlot` checks the photo's size before handing it on.
- **Edit Medal:** `EditMedalViewModel.addEventPhotos` checks each picked photo and stages the
  picked bytes. `EditMedalView` presents its error.
- **Shared code:** `AppError.photoTooLarge`, in English and Traditional Chinese. The 10 MB limit
  sits next to `UIImage.uploadData()`, and `StorageService` refuses an upload over it.
- **Storage rules:** every create and update needs a JPEG under 10 MB.
  `rules-tests/storage.test.js` covers it. The rules are deployed with the change
  (`cd rules-tests && npm run deploy`).
- **Design system:** the canvas says medals are saved as "840 × 840 JPEG". `deviations.md`
  records the difference until the designer updates it.
- **Data:** nothing in Firestore changes. Photo URLs, paths and the JPEG content type stay the
  same. Files grow: a face or logo can be several MB, and the medal wall downloads the full
  file for each face it shows.
