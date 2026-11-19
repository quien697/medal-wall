## 1. Photos at their own resolution

- [x] 1.1 Write tests in `MedalWallTests/Unit/Shared/UIImageExtensionsTests.swift` that
      `uploadData()` keeps the image's pixels (a 4000 × 3000 image encodes a 4000 × 3000 JPEG,
      both at scale 1 and as 2000 × 1500 points at scale 2), and that a HEIC photo, or a JPEG
      recording a GPS location, read with `UIImage(data:)` uploads as a JPEG with no location.
      The existing `uploadData()` passes them; they fail if it shrinks the image, keeps its
      format or keeps its metadata. Test photos come from `MedalWallTests/Support/TestPhotos`
- [x] 1.2 Write a `PhotoSlotViewModelTests` case: `framePickedPhoto` with 4000 × 3000 JPEG data
      puts a 4000 × 3000 photo in `photoToCrop`. The existing read passes it; it fails if the
      read shrinks the photo
- [x] 1.3 Write an `EditMedalViewModelTests` case: a picked 4000 × 3000 photo is staged as the
      picked bytes, unchanged. Written with 3.3, which changes `addEventPhotos`

## 2. Full-resolution framing (CropImage 2.0.1)

- [x] 2.1 Remove `outputSide` from `PhotoSlot` (the property, the `init` parameter, the doc
      comment and the `CropImageView` call) and from `EditMedalPhotosSection`
- [x] 2.2 Take CropImage from GitHub, up to the next major version from 2.0.1, and update
      `Package.resolved`

## 3. Photo Too Large

- [x] 3.1 Write failing tests in `LocalizedDisplayStringTests` for `AppError.photoTooLarge`'s
      title, message and guidance, then add the case with the English text from design.md and
      its zh-TW strings in `Localizable.xcstrings` (memory: script them, in
      `localizedStandardCompare` order). `AppError.sampleData` keeps one error per family, so
      `.photoDataInvalid` stays the media error there
- [x] 3.2 Write failing tests in `UIImageExtensionsTests` for the upload check: data of 10 MB
      less one byte passes and exactly 10 MB throws `.photoTooLarge`; a 3840 × 2880 image of
      seeded random noise (a JPEG over 10 MB) throws `.photoTooLarge`; a small image gives its
      JPEG. Add `UIImage.maxUploadByteCount`, `checkedUploadSize(_:)` and
      `checkedUploadData()`, all `nonisolated`, and have `StorageService` upload
      `checkedUploadData()`, to pass them
- [x] 3.3 Write failing `EditMedalViewModelTests` cases: `addEventPhotos` with a small photo,
      a noise photo and data that is not an image stages the small photo and throws
      `.photoTooLarge`; with valid photos and data that is not an image, it stages the valid
      ones and throws `.photoDataInvalid`. Make `addEventPhotos` `async`, measuring off the
      main actor, and await it in `EditMedalView`, to pass them
- [x] 3.4 Write failing `PhotoSlotViewModelTests` cases: checking a framed noise photo returns
      `.photoTooLarge`, and a small one returns `nil`. Have `PhotoSlot` run the check off the
      main actor before `onPick`, sending `.photoTooLarge` to `onError`, to pass them

## 4. Storage rules

- [x] 4.1 Write failing `rules-tests/storage.test.js` cases with an upload helper that takes a
      byte count: for an avatar, a medal face and an event photo, and for a race logo and an
      edition logo (including a logo before its race exists), a JPEG of 10 MB less one byte is
      accepted and one of exactly 10 MB is refused
- [x] 4.2 Replace `isJpeg()` with `isAllowedPhoto()` in `storage.rules`, adding the 10 MB cap
      and removing the MW-25 comment, to pass them (`cd rules-tests && npm test`)

## 5. Design system

- [x] 5.1 Add `component.MedalImage.saved` to `openspec/design-system/deviations.md` as
      design.md describes, with status `unreported`

## 6. Verify and ship

- [x] 6.1 Build, then run the full test suite and confirm the new test names appear in the
      run (memory: xcodebuild can run stale tests); run the rules tests
- [x] 6.2 On a device, with a 4000 × 4000 noise image (a JPEG over 10 MB): framing all of it
      shows Photo Too Large once the crop sheet closes, and the slot is unchanged; picking it as
      an event photo with valid photos adds the valid ones and shows Photo Too Large
- [ ] 6.3 On a device, watch memory while framing a 48 MP photo
- [ ] 6.4 Walk through each change and show the diff summary, then ask before committing
- [ ] 6.5 Ask before deploying the rules, then deploy with `cd rules-tests && npm run deploy`
