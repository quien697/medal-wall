## Why

MW-25's code review 2 found that a photo's size check leaves a gap: the check runs while the
form stays usable, so Remove Photo tapped during a crop's check is undone when the check ends
(#1), and the event photo picker can be reopened mid-check, adding the same photos twice (#2).
The crop flow that numbers crops and reports each check to the form also lives in `PhotoSlot`'s
closure, where it can't be tested (#5). Making the user wait for the check, visibly, closes the
gap instead of guarding against it. The review also found that a race or edition save refused
for a photo's size reports a generic save failure, not the Photo Too Large the spec names (#10).

## What Changes

- **Crops wait in the crop screen.** `PhotoSlot` uses CropImage 2.1.0's `onCrop` that waits and
  throws: after Confirm, the crop screen shows progress and can't be closed until the photo's
  size check ends. A photo under the limit closes the screen and fills the slot, as before.
- **A refused crop keeps the crop screen open.** Photo Too Large shows over it, with the
  guidance "Crop closer or choose a smaller photo.", so the user can crop closer and confirm
  again, or close. Picked and uploaded photos keep "Please choose a smaller photo."
- **Event photos show their check.** While picked event photos load and are checked, the add
  tile shows a spinner and can't open the photo library. Save keeps waiting for the check.
- **The crop flow moves into `PhotoSlotViewModel.confirmCrop(_:)`.** The crop numbering,
  `CropOutcome`, `PhotoSlot`'s `onCheckingChange` and `PhotoChecks` are removed: no form can
  be used while a crop is checked, and the medal form waits for one event photo check at a time.
- **Race and edition saves report Photo Too Large** when Storage's size check refuses their
  photo, as medal and profile saves already do.
- **Removed scenario:** Photo Size Check's "Cropping again during a check", since a crop can no
  longer be confirmed while another is checked. OpenSpec's archive refuses a modified
  requirement that drops a scenario, so archiving merges the Photo Size Check block into
  `openspec/specs/photo-uploads/spec.md` by hand, then archives with `--skip-specs`.

## Capabilities

### New Capabilities

### Modified Capabilities
- `photo-uploads`: Photo Size Check — the crop screen waits for a crop's check and stays open
  when it refuses the crop, a refused crop gets its own guidance, and the event photo add tile
  shows the check and can't be used until it ends.

## Impact

- **Dependency:** CropImage minimum version 2.0.1 → 2.1.0.
- **Code:** `PhotoSlot`, `PhotoSlotViewModel`, `CroppedPhoto`, `AppError` (new
  `.croppedPhotoTooLarge`), `EditMedalViewModel` (event photo loading and a checking flag),
  `EditMedalView`, `EditMedalEventPhotosSection`, `EditMedalPhotosSection`, and the profile,
  race and edition forms and view models (`onCheckingChange` and `canSave` removed; Save follows
  `isFormValid` again). `PhotoChecks` and its tests are deleted.
- **Strings:** "Crop closer or choose a smaller photo.", with zh-TW.
