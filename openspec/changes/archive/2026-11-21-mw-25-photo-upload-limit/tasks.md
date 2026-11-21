## 1. Photos at their own resolution

- [x] 1.1 Write tests in `MedalWallTests/Unit/Shared/UIImageExtensionsTests.swift` that
      `uploadData()` keeps the image's pixels (a 4000 × 3000 image encodes a 4000 × 3000 JPEG,
      both at scale 1 and as 2000 × 1500 points at scale 2), and that a HEIC photo, or a JPEG
      recording a GPS location, read with `UIImage(data:)` uploads as a JPEG with no location.
      The existing `uploadData()` passes them; they fail if it shrinks the image, keeps its
      format or keeps its metadata. Test photos come from `MedalWallTests/Support/TestPhotos`
- [x] 1.2 Write a `PhotoSlotViewModelTests` case: `cropPickedPhoto` with 4000 × 3000 JPEG data
      puts a 4000 × 3000 photo in `photoToCrop`. The existing read passes it; it fails if the
      read shrinks the photo
- [x] 1.3 Write an `EditMedalViewModelTests` case: a picked 4000 × 3000 photo is staged as its
      checked JPEG, still 4000 × 3000. Written with 3.3, which changes `addEventPhotos`

## 2. Full-resolution cropping (CropImage 2.0.1)

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
- [x] 3.4 Write failing `PhotoSlotViewModelTests` cases: checking a cropped noise photo returns
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
- [x] 6.2 On a device, with a 4000 × 4000 noise image (a JPEG over 10 MB): cropping all of it
      shows Photo Too Large once the crop sheet closes, and the slot is unchanged; picking it as
      an event photo with valid photos adds the valid ones and shows Photo Too Large
- [x] 6.3 On a device, watch memory while cropping a 48 MP photo
- [x] 6.4 Walk through each change and show the diff summary, then ask before committing
- [x] 6.5 Ask before deploying the rules, then deploy with `cd rules-tests && npm run deploy`

## 7. Waiting for checks

- [x] 7.1 Make the `storage.rules` comment describe the cap for every client; the rules tests
      pass
- [x] 7.2 Write failing `PhotoChecksTests`: overlapping checks keep a photo being checked until
      the last ends, and a check end with no start is ignored; and in the profile, race, edition
      and medal view model tests, `canSave` needs a valid form and no check in progress. Add
      `PhotoChecks` (and to the test target's include list) and `canSave` to each form, drive
      Save with `canSave`, and count an event-photo pick from loading to the end of its check,
      to pass them
- [x] 7.3 Write a failing `PhotoSlotViewModelTests` case: a crop begun before a newer one is
      `.superseded` whichever check ends first. Number crops with `LoadSequence`, return
      `CropOutcome`, and report checks through `PhotoSlot`'s `onCheckingChange`, to pass
      it
- [x] 7.4 Write a failing `EditRaceEditionViewModelTests` case: a cropped photo is staged as the
      cropped photo itself. Replace `DraftRaceEdition.newPhotoData` with `newPhoto` to pass it
- [x] 7.5 Free each event photo's buffers before checking the next
- [x] 7.6 Add `CroppedPhoto` (and to the test target's include list), the image and its checked
      JPEG: `PhotoSlot` hands it to `onPick`, the forms stage it, event photos stage their
      checked JPEG, and `PhotoStorage`, `StorageService` and `UserManager.updateUser` take the
      checked JPEG, so no save encodes a photo again. `checkedUploadData()`,
      `checkedUploadSize(_:)` and `CroppedPhoto(checking:)` throw only `AppError`. Tests: a
      cropped photo is handed over with its checked JPEG, a picked photo is staged as its
      checked JPEG at its own pixel size, and the profile's photo to upload is the cropped
      photo's JPEG
- [x] 7.7 Build, run the full test suite and the rules tests, then redeploy the rules

## 8. Shared form state

- [x] 8.1 Write failing `DraftPhotoTests`: a photo with a stored copy is loading it, shows it
      once downloaded or marks it failed, keeps a photo already shown when a later download
      fails, and ignores a download after a crop or removal; cropping and removing are
      changes, a staged photo is not, and a saved photo no longer is. Add `DraftPhoto` (and to
      the test target's include list), holding its slot's `PhotoSlotContent`, to pass them, then
      keep the profile, race and edition forms' photo in one and each medal face in one
- [x] 8.2 Have `PhotoSlot` take `content:`, and remove `StoredPhotoStatus` and
      `PhotoSlotViewModel.content(photo:storedPhotoStatus:)`. Move `PhotoSlotContent` to
      `Shared/UIModels` (and onto the test target's include list) and `PickedPhoto` to
      `PhotoSlot/Models`, and point the `design-system-sync` skill at the new path
- [x] 8.3 Write failing `RaceDistanceCategoryTests` cases: a standard distance, or a valid custom
      one, is valid. Add `isValid` to pass them, and use it in the edition form's `addDistance`
      and the medal form's `selectDistance` and `isFormValid`
- [x] 8.4 Build and run the full test suite, confirming the new test names appear in the run

## 9. Consistent names

- [x] 9.1 Name the crop step crop throughout, as CropImage does: `CroppedPhoto`, `CropOutcome`,
      `cropPickedPhoto(_:)`, `beginCrop()` and `checkCroppedPhoto(_:crop:)`, with the docs,
      test names and specs to match, and the `medal-photos` requirement Square Crop
- [x] 9.2 Say stored for a form's saved photo (`loadStoredPhoto()`, `loadStoredPhotos()`,
      `DraftRaceEdition.storedPhotoUrl`), remove for taking it out of the form (`remove()`,
      `removePhoto(for:)`, `DraftRaceEdition.isPhotoRemoved`), and photo for an edition's
      (`uploadRaceEditionPhoto`), keeping its Storage folder `editionLogo`
- [x] 9.3 Build and run the full test suite, confirming the renamed tests appear in the run
