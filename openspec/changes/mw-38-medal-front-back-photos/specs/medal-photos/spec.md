## ADDED Requirements

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

### Requirement: Photo Tips
Starting a photo for a face SHALL first present a tip sheet. It SHALL name the face
("Photograph the front" or "Photograph the back"), say that the background will be removed,
and recommend laying the medal flat in even daylight with no flash, shot from straight above,
or hanging it against a plain wall with nothing in front of it. It SHALL offer **Choose
photo**, which opens the photo library, and **Take photo**, which opens the system camera with
no guide overlay. Take photo SHALL NOT be offered when the device has no camera. Dismissing
the sheet SHALL leave the slot unchanged.

#### Scenario: The tip sheet names the face
- **WHEN** a user taps the empty Back slot
- **THEN** the tip sheet reads "Photograph the back" and offers Choose photo and Take photo

#### Scenario: A device without a camera
- **WHEN** the tip sheet opens on a device with no camera
- **THEN** it offers Choose photo only

#### Scenario: Dismissing the tips
- **WHEN** a user dismisses the tip sheet without choosing or taking a photo
- **THEN** the slot is unchanged

### Requirement: Square Framing
After a photo is chosen or taken, the user SHALL frame the medal in a square on the original
photo, by pinching and dragging. Whatever lies outside the square SHALL be cut off, so the
square's top edge is where the ribbon is trimmed. Medal photos SHALL NOT be cropped to a
circle. Cancelling the framing SHALL leave the slot unchanged.

#### Scenario: Framing cuts off the surroundings
- **WHEN** a photo shows the medal with a hand and a table edge outside the framed square
- **THEN** the saved photo holds only what lies inside the square

#### Scenario: Cancelling the framing
- **WHEN** a user cancels the framing
- **THEN** the slot is unchanged, and the photo is not used

### Requirement: On-Device Background Removal
Once a square is framed, the system SHALL remove its background on the device, processing only
the framed square and sending the photo nowhere. While the background is being cleared, the
slot SHALL show that it is working, and the medal SHALL NOT be savable. When it finishes, the
cutout SHALL appear in the slot with no further confirmation; replacing the photo is the way
to undo it.

When no medal can be picked out of the square, the system SHALL say "We couldn't pick out a
medal in this square. Try a photo where it's flat or hanging, in even light, with nothing
covering it." and offer **Reframe**, which returns to the framing with the same photo, and
**Cancel**, which leaves the slot unchanged. It SHALL NOT offer to keep the photo with its
background.

#### Scenario: The cutout drops into the slot
- **WHEN** the background is cleared from a framed square
- **THEN** the slot shows the medal on a transparent background, with no confirmation step

#### Scenario: Saving waits for the cutout
- **WHEN** a background is still being cleared
- **THEN** the slot shows that it is working and the medal cannot be saved

#### Scenario: No medal found, then reframed
- **WHEN** no medal can be picked out of a framed square and the user taps Reframe
- **THEN** the framing reopens with the same photo

#### Scenario: No medal found, then cancelled
- **WHEN** no medal can be picked out of a framed square and the user taps Cancel
- **THEN** the slot is unchanged

### Requirement: Stored Medal Photo
Each face SHALL be stored as an 840 × 840 PNG whose background is transparent, so the medal
keeps its own outline wherever it is shown.

#### Scenario: A saved face keeps its transparency
- **WHEN** a medal is saved with a front cutout and shown again later
- **THEN** the front shows the medal with no background behind it

#### Scenario: A face is stored at 840 × 840
- **WHEN** a framed and cleared face is saved
- **THEN** the stored image is an 840 × 840 PNG

### Requirement: Edit Form Photo Slots
The medal form SHALL show two square slots side by side, Front then Back, each labelled with
its face. An empty slot SHALL read "Add front" or "Add back", and tapping it SHALL start the
photo flow for that face. Tapping a filled slot SHALL offer **Replace Photo**, which starts the
photo flow for that face, **Remove Photo**, and **Cancel**. The slots SHALL never change places,
whichever face is filled. A change to either face SHALL be staged in the form and reach
storage only when the medal is saved.

#### Scenario: An empty slot starts the flow
- **WHEN** a user taps the empty Front slot
- **THEN** the tip sheet for the front opens

#### Scenario: A filled slot offers its options
- **WHEN** a user taps the filled Back slot
- **THEN** Replace Photo, Remove Photo and Cancel are offered for the back photo

#### Scenario: Cancelling the form keeps the stored photos
- **WHEN** a user replaces the front in the form and then cancels it
- **THEN** the medal still shows its previous front, and nothing is uploaded

### Requirement: Medal Image Presentation
Wherever a medal's image is shown — the collection list, search results and the details —
the system SHALL show the medal as a square with `radius.image` corners, filled with the card
colour and edged with a hairline: 280 pt in the details, 96 pt in the list and 46 pt in search.
The list and search SHALL show the front. The cutout's shadow SHALL follow the medal's own
outline, with the square itself flat. A medal image SHALL carry no gold ring or bar, whether or
not its result is recorded.

Without a front, the list and the details SHALL show a placeholder of a medal glyph labelled
"Front", and search SHALL show the glyph alone. The personal-best carousel SHALL show no medal
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
