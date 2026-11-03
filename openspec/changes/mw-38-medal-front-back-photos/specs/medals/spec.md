## MODIFIED Requirements

### Requirement: Medal Record Management
The system SHALL allow a signed-in user to create, read, update, and delete a `Medal`
record, scoped to that user only, recording race name, date, bib number, place,
distance, optional finish time, optional overall/division/gender placements, optional
division (gender + age group), optional notes, tags, an optional front photo, an optional
back photo, and an event photo gallery. A medal's place SHALL follow the shape defined by the
`place-entry` capability, which owns the representation of a place and how one is chosen. A
medal's front and back photos SHALL follow the `medal-photos` capability.

Every photo upload SHALL go to a new storage location, never over a file a medal points at.
A photo the medal no longer holds — a removed or replaced front, back or event photo, or every
photo of a deleted medal — SHALL be deleted from storage, and only after the medal's save or
delete succeeds, so a medal never points at a deleted file. A photo uploaded for a save that
fails SHALL be deleted. A photo that fails to delete is left in storage rather than failing a
save or delete.

#### Scenario: Create a medal
- **WHEN** a user submits a new medal with a race name, date, bib number, place,
  and distance
- **THEN** the system creates a `Medal` record under that user's medals

#### Scenario: Medals are private to their owner
- **WHEN** any user's medal list is fetched
- **THEN** the system only returns medals belonging to the requesting user's uid

#### Scenario: Remove a medal's photos
- **WHEN** a user removes a medal's front, its back or any of its event photos and the medal
  save succeeds
- **THEN** the system deletes each removed photo from storage

#### Scenario: Replace a medal's front photo
- **WHEN** a user replaces the front photo of a medal that has one and the medal save
  succeeds
- **THEN** the medal shows the new front and the old one is deleted from storage, and its
  back is untouched

#### Scenario: Medal save fails after changing photos
- **WHEN** a user removes or replaces a medal's front, back or event photos and the medal save
  fails
- **THEN** the old photos stay in storage, the medal still shows them, and any photo uploaded
  for the save is deleted

#### Scenario: Delete a medal
- **WHEN** a user deletes a medal and the delete succeeds
- **THEN** the system deletes its front, its back and every event photo from storage; if the
  delete fails, the medal and all its photos remain

### Requirement: Event Photo Gallery
The system SHALL allow a medal to have zero or more additional event photos, separate
from its front and back photos.

#### Scenario: Add event photos to a medal
- **WHEN** a user adds one or more event photos to a medal
- **THEN** the system stores them as an ordered list on that medal, distinct from the
  medal's front and back photos
