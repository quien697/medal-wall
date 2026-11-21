## ADDED Requirements

### Requirement: Photos Kept At Their Own Resolution
A stored photo SHALL keep the pixels it was picked, taken or cropped with, and SHALL NOT be
shrunk or enlarged. An event photo SHALL be stored at the picked photo's size. A cropped photo
(a profile photo, a medal face, a race logo or an edition photo) SHALL be the photo's own
pixels inside the cropped square, so its side is the number of the photo's pixels the square
covers.

#### Scenario: A large event photo
- **WHEN** a user saves a medal with an event photo picked at 6000 × 4000 whose JPEG is under
  10 MB
- **THEN** the stored event photo is 6000 × 4000

#### Scenario: A cropped medal face
- **WHEN** a user crops a front photo to a square that covers 2729 pixels of a
  3024 × 3024 photo, and saves the medal
- **THEN** the stored front is 2729 × 2729

#### Scenario: A medal cropped closely
- **WHEN** the cropped square covers 400 pixels of the photo
- **THEN** the stored face is 400 × 400, not enlarged

#### Scenario: A cropped profile photo
- **WHEN** a user crops a profile photo to a square that covers 1500 pixels of the photo,
  and saves the profile
- **THEN** the stored profile photo is 1500 × 1500

### Requirement: Stored Photo Format
Every photo the system stores SHALL be a JPEG, whatever format it was picked or taken in.

#### Scenario: A HEIC photo is stored
- **WHEN** a user saves a photo picked from the library as HEIC
- **THEN** the stored photo is a JPEG

### Requirement: No Picked-File Metadata
A stored photo SHALL NOT carry the metadata of the file it was picked from, such as the GPS
location where it was taken.

#### Scenario: A photo with a location
- **WHEN** a user saves an event photo whose file records the GPS location it was taken at
- **THEN** the stored photo holds no location

### Requirement: Photo Size Check
The app SHALL refuse a photo whose JPEG is 10 MB (10 × 1024 × 1024 bytes) or more: an event
photo when it is picked, a cropped photo when its crop is confirmed, and any photo before it
is uploaded. The size that counts SHALL be the JPEG the app uploads, not the picked file. A
refused photo SHALL NOT be added, and the app SHALL show "Photo Too Large", "Photos must be
under 10 MB." and "Please choose a smaller photo." When several event photos are picked
together, the others SHALL still be added. Save SHALL be unavailable while a picked or cropped
photo is still being checked, so no photo is left out of a save. When a slot's photo is cropped
again before an earlier crop's check ends, only the newer photo SHALL be used.

#### Scenario: An event photo over the limit
- **WHEN** a user picks three event photos and one of them is 10 MB or more as a JPEG
- **THEN** the other two are added, and the app shows Photo Too Large

#### Scenario: A cropped photo over the limit
- **WHEN** a user confirms the crop of a front photo whose JPEG is 10 MB or more
- **THEN** the slot is unchanged, and the app shows Photo Too Large

#### Scenario: A photo under the limit
- **WHEN** a user picks an event photo whose JPEG is under 10 MB
- **THEN** it is added

#### Scenario: Saving while a photo is being checked
- **WHEN** a user picks event photos and they are still being checked
- **THEN** Save is unavailable until the check ends, and the saved medal includes the photos

#### Scenario: Cropping again during a check
- **WHEN** a user crops a front photo, then crops another before the first one's check ends
- **THEN** the slot shows the second photo

#### Scenario: A photo over the limit at save
- **WHEN** a save would upload a photo whose JPEG is 10 MB or more
- **THEN** the save fails with Photo Too Large, and the medal, profile, race or edition is
  not saved

### Requirement: Upload Size Cap
Storage SHALL refuse a photo upload of 10 MB (10 × 1024 × 1024 bytes) or more at every path
that accepts photos, whichever client sends it. A save whose upload is refused SHALL fail as a
save whose upload fails for any other reason.

#### Scenario: A photo under the cap
- **WHEN** a signed-in user uploads a JPEG of 10 MB less one byte to a path they may write
- **THEN** Storage accepts it

#### Scenario: A photo at the cap
- **WHEN** a signed-in user uploads a JPEG of exactly 10 MB to a path they may write
- **THEN** Storage refuses it

#### Scenario: A logo uploaded before its race exists
- **WHEN** a signed-in user uploads a 10 MB JPEG as the logo of a race that does not exist yet
- **THEN** Storage refuses it
