# medal-photos Specification

## Purpose
A medal's front and back photos: how each face is chosen or taken and cropped to a square,
how the edit form's photo slots behave, and how a medal image is shown across the app.
## Requirements
### Requirement: Front And Back Photos
A medal SHALL hold up to two photos of itself, a front and a back. Each SHALL be optional and
independent of the other — a medal can have neither, either one, or both — and adding,
replacing or removing one face SHALL leave the other as it was.

#### Scenario: A medal with no photos
- **WHEN** a user saves a medal without adding a front or a back
- **THEN** the medal saves, and shows the front placeholder wherever its image appears

#### Scenario: Removing the front keeps the back
- **WHEN** a medal has both faces and the user removes the front and saves
- **THEN** the medal keeps its back, and the back stays in its own slot

#### Scenario: A back without a front
- **WHEN** a medal has a back photo and no front photo
- **THEN** the list and search show the front placeholder, and the details can still show
  the back

### Requirement: Photo Source
Tapping a face's slot SHALL offer, titled "Front photo" or "Back photo", **Choose Photo**, which
opens the photo library, **Take Photo**, which opens the system camera with no guide overlay,
and **Cancel**. A filled slot SHALL also offer **Remove Photo**. The options SHALL say how to
photograph the medal against a clear background: "Lay it flat on a plain surface and shoot from
straight above, or hang it on a plain wall. Keep everything else out of the shot, and use even
light with no flash." Cancelling SHALL leave the slot unchanged.

Take Photo SHALL be offered whether or not the camera can open. Tapping it SHALL open the camera
when camera access is allowed, and SHALL let iOS ask for access first when the app has not asked
yet. When access is turned off or restricted, it SHALL say "Turn on camera access in Settings to
take a photo." and offer **Open Settings**. When the device has no camera, it SHALL say "This
device has no camera. Choose a photo instead." Neither SHALL change the slot.

#### Scenario: The choice names the face
- **WHEN** a user taps the empty Back slot
- **THEN** "Back photo" offers Choose Photo, Take Photo and Cancel

#### Scenario: The choice says how to shoot the medal
- **WHEN** a user taps either slot
- **THEN** the options say to lay the medal flat on a plain surface or hang it on a plain wall,
  with everything else out of the shot, in even light with no flash

#### Scenario: Taking the first photo asks for camera access
- **WHEN** a user taps Take Photo before the app has asked for camera access
- **THEN** iOS asks, and the camera opens if the user allows it

#### Scenario: Camera access is turned off
- **WHEN** a user taps Take Photo with camera access turned off in Settings
- **THEN** the app says to turn on camera access in Settings, offers Open Settings, and the slot
  is unchanged

#### Scenario: A device without a camera
- **WHEN** a user taps Take Photo on a device with no camera
- **THEN** the app says the device has no camera, and the slot is unchanged

#### Scenario: Cancelling the choice
- **WHEN** a user cancels without choosing or taking a photo
- **THEN** the slot is unchanged

### Requirement: Square Crop
After a photo is chosen or taken, the user SHALL crop the medal to a square on the original
photo, by pinching and dragging. Whatever lies outside the square SHALL be cut off, so the
square's top edge is where the ribbon is trimmed. Medal photos SHALL NOT be cropped to a
circle. Once cropped, the photo SHALL appear in the slot with no further step; choosing or
taking another photo is the way to replace it. Cancelling the crop SHALL leave the slot
unchanged.

#### Scenario: The crop cuts off the surroundings
- **WHEN** a photo shows the medal with a hand and a table edge outside the cropped square
- **THEN** the saved photo holds only what lies inside the square

#### Scenario: The cropped photo drops into the slot
- **WHEN** a user confirms a cropped square
- **THEN** the slot shows the cropped photo, with no confirmation step

#### Scenario: Cancelling the crop
- **WHEN** a user cancels the crop
- **THEN** the slot is unchanged, and the photo is not used

### Requirement: Edit Form Photo Slots
The medal form SHALL show two square slots side by side, Front then Back, each labelled with
its face. An empty slot SHALL read "Add front" or "Add back". Tapping a slot SHALL start the
photo flow for that face, and a filled slot SHALL also offer to remove its photo. The slots
SHALL never change places,
whichever face is filled. A change to either face SHALL be staged in the form and reach
storage only when the medal is saved.

#### Scenario: An empty slot starts the flow
- **WHEN** a user taps the empty Front slot
- **THEN** Choose Photo and Take Photo are offered for the front photo

#### Scenario: A filled slot offers its options
- **WHEN** a user taps the filled Back slot
- **THEN** Choose Photo, Take Photo, Remove Photo and Cancel are offered for the back photo

#### Scenario: Cancelling the form keeps the stored photos
- **WHEN** a user replaces the front in the form and then cancels it
- **THEN** the medal still shows its previous front, and nothing is uploaded

### Requirement: Medal Image Presentation
Wherever a medal's image is shown — the collection list, search results and the details —
the system SHALL show the medal as a square with `radius.image` corners, drawn as every other
photo is: 280 pt in the details, 96 pt in the list and 46 pt in search. The list and search
SHALL show the front. The photo SHALL fill the square, and the square SHALL cast no shadow. A medal image SHALL carry no gold ring or bar, whether or not its result is
recorded.

Without a front, the list and the details SHALL show the photo placeholder's medal glyph
labelled "Front", and search SHALL show the glyph alone. The personal-best carousel SHALL show no medal
image. Avatars SHALL stay circles.

#### Scenario: The list shows the front
- **WHEN** a medal with a front and a back appears in the collection list
- **THEN** its row shows the front in a 96 pt square

#### Scenario: A medal without a front in the list
- **WHEN** a medal with no front photo appears in the collection list
- **THEN** its row shows the medal glyph labelled "Front" in the square

#### Scenario: No gold on a medal image
- **WHEN** a medal with a recorded finish time and a medal without one appear in the list
- **THEN** neither image carries a gold ring or bar

#### Scenario: The personal-best carousel has no image
- **WHEN** the personal-best carousel shows a record
- **THEN** it shows no medal image

#### Scenario: Avatars are unchanged
- **WHEN** the profile shows the user's photo
- **THEN** it is a circle, as before
