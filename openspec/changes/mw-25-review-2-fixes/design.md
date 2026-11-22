## Context

Every cropped photo (profile photo, medal faces, race logo, edition photo) goes through
`PhotoSlot`, which presents CropImage's `CropImageView`. Event photos are picked in
`EditMedalView` and checked by `EditMedalViewModel.addEventPhotos`. Each check encodes the
photo as the JPEG to upload and refuses one of 10 MB or more. Encoding takes about 45 ms for a
12 MP square crop and about 180 ms for a 48 MP one, and 100–400 ms per event photo (Simulator).

CropImage 2.1.0's `onCrop` can wait and throw: while it runs, Confirm shows progress, Close,
the photo's pan and pinch and swipe-to-dismiss are disabled; when it returns the screen
closes, and when it throws the screen stays open with its framing and Confirm works again.
CropImage shows no message of its own.

## Goals / Non-Goals

**Goals:**
- Nothing in a form can change while one of its photos is checked, so no result lands late.
- A refused crop can be fixed in the crop screen, without picking the photo again.
- The check has no logic in views: the crop and event photo flows are view model calls, tested.

**Non-Goals:**
- A progress count for event photos, or cancelling a check.
- Changing the size limit, the encoding, or what save uploads.

## Decisions

### A crop is checked inside the crop screen
`PhotoSlot` passes CropImage `{ onPick(try await viewModel.confirmCrop($0)) }`.
`PhotoSlotViewModel.confirmCrop(_:)` throws `.photoDataInvalid` for a missing image (CropImage
failed to render), and otherwise encodes and checks it off the main actor (`@concurrent`), so
the progress keeps turning, and returns the `CroppedPhoto`. A photo under the limit reaches
`onPick` and the crop screen closes. A refused one throws, so the crop screen stays open.

The form behind the crop screen can't be used during the check, so a crop can't be removed,
replaced or left out of a save while it is checked. The crop numbering, `CropOutcome`,
`PhotoSlot`'s `onCheckingChange` and `PhotoChecks` are removed, and the profile, race and
edition forms enable Save from `isFormValid`.

### A refused crop shows over the crop screen
`confirmCrop(_:)` sets the view model's `error` before throwing. `PhotoSlot` follows the
project's error bridge: `.onChange(of: viewModel.error)` wraps it in a local `ErrorWrapper`, and
an `ErrorView` sheet attached to the `CropImageView`, inside the crop sheet, presents it, then
resets `viewModel.error` on dismiss. Dismissing it returns to the crop screen as it was.
Errors before the crop screen opens (a picked file that isn't an image) still reach `onError`.

### A crop has its own guidance
`CroppedPhoto(checking:)`, made only from crops, throws `AppError.croppedPhotoTooLarge` for a
JPEG at or over the limit. Its title and message are Photo Too Large's ("Photo Too Large",
"Photos must be under 10 MB."), and its guidance is "Crop closer or choose a smaller photo."
(zh-TW 「請縮小裁切範圍，或選擇較小的照片。」). Event photos and `StorageService`'s upload
guard keep `.photoTooLarge` and "Please choose a smaller photo."

### Event photos are loaded and checked by the view model
`EditMedalViewModel.addEventPhotos(from:)` takes the picked `PhotosPickerItem`s. It sets
`isCheckingEventPhotos` from the start of loading to the end of the check, loads each item
through an injected `loadPickedPhoto` (by default `loadTransferable(type: Data.self)`), counts
an item that fails to load as not an image, and hands the rest to `addEventPhotos(_:)`. It
throws `.photoTooLarge` if any item was too large, and otherwise `.photoDataInvalid` if any was
not an image. `canSave` is `isFormValid && !isCheckingEventPhotos`.

`EditMedalView` clears the picker selection as soon as it takes the items, then calls
`addEventPhotos(from:)`. `EditMedalEventPhotosSection` takes `isChecking`: while it is true,
the add tile becomes a checking tile that can't be tapped: a `ProgressView` at the event
thumbnail size, ringed with the 1 pt `Color.Border.primary` edge of a loading `PhotoSlot`. The picker can't be reopened, so one
check runs at a time and no photo is added twice.

### CropImage 2.1.0
The project's CropImage requirement moves to 2.1.0 (up to the next major).

## Risks / Trade-offs

- [Waiting on a large crop] A 48 MP crop keeps the crop screen up for about 0.2 s with progress
  showing. → Checked on a device.
- [Waiting on many event photos] 10 large event photos keep the add tile checking for a few
  seconds. → The tile says so, and the rest of the form stays usable.
- [ErrorView over a sheet] It is presented from inside the crop sheet, since the form can't
  present while that sheet is up. → Checked on a device with a crop over the limit.
