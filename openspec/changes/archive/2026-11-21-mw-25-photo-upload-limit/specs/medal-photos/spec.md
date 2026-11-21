## RENAMED Requirements
- FROM: `### Requirement: Square Framing`
- TO: `### Requirement: Square Crop`

## MODIFIED Requirements

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

## REMOVED Requirements

### Requirement: Stored Medal Photo
**Reason**: A face is stored at the photo's own pixels inside the cropped square, as the
`photo-uploads` requirement Photos Kept At Their Own Resolution sets for every cropped photo.

**Migration**: Faces already stored stay 840 × 840. Faces saved from this change on are the
cropped square at the photo's own resolution. Nothing reads a face's pixel size: every view
draws it at its own display size.
