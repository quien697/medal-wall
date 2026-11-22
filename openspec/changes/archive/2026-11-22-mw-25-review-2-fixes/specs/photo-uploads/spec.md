## MODIFIED Requirements

### Requirement: Photo Size Check
The app SHALL refuse a photo whose JPEG is 10 MB (10 × 1024 × 1024 bytes) or more: an event
photo when it is picked, a cropped photo when its crop is confirmed, and any photo before it
is uploaded. The size that counts SHALL be the JPEG the app uploads, not the picked file. A
refused photo SHALL NOT be added, and the app SHALL show "Photo Too Large" and "Photos must be
under 10 MB.", followed by "Crop closer or choose a smaller photo." for a crop and "Please
choose a smaller photo." otherwise. When several event photos are picked together, the others
SHALL still be added.

The crop screen SHALL stay open while its crop is checked, showing progress in place of
Confirm, and SHALL NOT let the user close it or move the photo until the check ends. A crop
under the limit SHALL then close the crop screen and fill the slot. A refused crop SHALL keep
the crop screen open with its framing, with Photo Too Large shown over it, so the user can crop
closer and confirm again, or close it.

While picked event photos are loaded and checked, the event photos' add tile SHALL show a
spinner and SHALL NOT open the photo library, and Save SHALL be unavailable, so no photo is left
out of a save or added twice.

#### Scenario: An event photo over the limit
- **WHEN** a user picks three event photos and one of them is 10 MB or more as a JPEG
- **THEN** the other two are added, and the app shows Photo Too Large with "Please choose a
  smaller photo."

#### Scenario: A cropped photo over the limit
- **WHEN** a user confirms the crop of a front photo whose JPEG is 10 MB or more
- **THEN** the crop screen stays open with the same framing, the app shows Photo Too Large
  over it with "Crop closer or choose a smaller photo.", and the slot is unchanged

#### Scenario: Cropping closer after a refusal
- **WHEN** a user dismisses Photo Too Large on the crop screen, crops closer so the JPEG is
  under 10 MB, and confirms
- **THEN** the crop screen closes, and the slot shows the closer crop

#### Scenario: A crop being checked
- **WHEN** a user confirms a crop and its check has not ended
- **THEN** the crop screen shows progress in place of Confirm, and the user can't close it or
  move the photo

#### Scenario: A photo under the limit
- **WHEN** a user picks an event photo whose JPEG is under 10 MB
- **THEN** it is added

#### Scenario: Saving while a photo is being checked
- **WHEN** a user picks event photos and they are still being checked
- **THEN** Save is unavailable until the check ends, and the saved medal includes the photos

#### Scenario: Choosing more event photos during a check
- **WHEN** picked event photos are still being checked
- **THEN** the add tile shows a spinner and tapping it doesn't open the photo library, until
  the check ends

#### Scenario: A photo over the limit at save
- **WHEN** a save would upload a photo whose JPEG is 10 MB or more
- **THEN** the save fails with Photo Too Large, and the medal, profile, race or edition is
  not saved
