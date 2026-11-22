## 1. CropImage 2.1.0

- [x] 1.1 Take CropImage up to the next major version from 2.1.0, resolve packages, and confirm
      `Package.resolved` pins 2.1.0 and the app builds

## 2. A crop's own guidance

- [x] 2.1 Write failing tests in `LocalizedDisplayStringTests` for
      `AppError.croppedPhotoTooLarge`'s title, message and guidance, then add the case with the
      text from design.md and the zh-TW guidance in `Localizable.xcstrings` (memory: script it,
      in `localizedStandardCompare` order)
- [x] 2.2 Write a failing `CroppedPhotoTests` case: a JPEG over the limit throws
      `.croppedPhotoTooLarge`; then make `CroppedPhoto(checking:)` throw it

## 3. The crop is checked in the crop screen

- [x] 3.1 Replace the three crop-check tests in `PhotoSlotViewModelTests` with failing
      `confirmCrop(_:)` tests: a photo under the limit returns its `CroppedPhoto` with its
      checked JPEG and leaves `error` nil; one over the limit throws and sets `error` to
      `.croppedPhotoTooLarge`; a missing image throws and sets `.photoDataInvalid`
- [x] 3.2 Add `confirmCrop(_:)` and `error` to `PhotoSlotViewModel`; remove the crop numbering,
      `beginCrop`, `CropOutcome` and `checkCroppedPhoto`
- [x] 3.3 In `PhotoSlot`, pass CropImage `{ onPick(try await viewModel.confirmCrop($0)) }`, and
      present `viewModel.error` as `ErrorView` from a sheet attached to the `CropImageView`
      (error bridge, reset on dismiss); update the doc comment and previews
- [x] 3.4 Remove `onCheckingChange` from `PhotoSlot`, `EditMedalPhotosSection` and the profile,
      race, edition and medal forms

## 4. Save follows the form again

- [x] 4.1 Remove `photoChecks` and `canSave` from the profile, race and edition view models and
      their Save-while-checking tests; their Save buttons follow `isFormValid`
- [x] 4.2 Delete `PhotoChecks.swift` and `PhotoChecksTests.swift`

## 5. Event photos show their check

- [x] 5.1 Write failing `EditMedalViewModelTests`: `addEventPhotos(from:)` (items made with
      `PhotosPickerItem(itemIdentifier:)`, loader injected) stages every loaded photo; counts
      an item that fails to load as not an image and throws `.photoDataInvalid`; throws
      `.photoTooLarge` over `.photoDataInvalid`; holds `isCheckingEventPhotos` and `canSave`
      false while a load is suspended, and releases both when it ends
- [x] 5.2 Add `isCheckingEventPhotos`, the injected `loadPickedPhoto` and
      `addEventPhotos(from:)` to `EditMedalViewModel`; `canSave` reads the flag; replace the
      medal Save-while-checking test that used `photoChecks`
- [x] 5.3 In `EditMedalView`, clear the picker selection as soon as the items are taken, then
      call `addEventPhotos(from:)` and present its error
- [x] 5.4 Give `EditMedalEventPhotosSection` `isChecking` and the checking tile from design.md,
      add a checking `#Preview`

## 6. Race and edition saves

- [x] 6.1 Write failing `EditRaceViewModelStorageTests` cases: a new race's logo, an existing
      race's logo and an edition photo that Storage refuses as too large each fail the save with
      `.photoTooLarge`; then pass it through in `EditRaceViewModel`
- [x] 6.2 Build `checkedJPEGs`' result with `Result`'s typed `init(catching:)`

## 7. Verify

- [x] 7.1 Build, then run the full test suite and confirm the new test names appear in the run
      (memory: xcodebuild can run stale tests); run swift-format lint and SwiftLint
- [x] 7.2 Check the previews: the checking tile in light and dark
- [x] 7.3 On a device: confirm a 48 MP crop (progress, then the slot fills); a crop over 10 MB
      (Photo Too Large over the crop screen, then crop closer and confirm); 10 event photos
      (the add tile shows a spinner, Save waits, no photo twice)
- [x] 7.4 Walk through each change and show the diff summary, then ask before committing
