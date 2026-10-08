# medals Specification

## Purpose
Let a signed-in user record and manage their race medals — full CRUD over a `Medal`'s
race details, results, photos, and event photo gallery — with every medal kept private
to its owner.
## Requirements
### Requirement: Medal Record Management
The system SHALL allow a signed-in user to create, read, update, and delete a `Medal`
record, scoped to that user only, recording race name, date, bib number, place,
distance, optional finish time, optional overall/division/gender placements, optional
division (gender + age group), optional notes, tags, an optional cover photo, and an
event photo gallery. A medal's place SHALL follow the shape defined by the `place-entry`
capability, which owns the representation of a place and how one is chosen.

A photo the medal no longer holds — a removed cover or event photo, or every photo of a
deleted medal — SHALL be deleted from storage, and only after the medal's save or delete
succeeds, so a medal never points at a deleted file. A photo that fails to delete after that
is left in storage rather than failing a save or delete that already happened.

#### Scenario: Create a medal
- **WHEN** a user submits a new medal with a race name, date, bib number, place,
  and distance
- **THEN** the system creates a `Medal` record under that user's medals

#### Scenario: Medals are private to their owner
- **WHEN** any user's medal list is fetched
- **THEN** the system only returns medals belonging to the requesting user's uid

#### Scenario: Remove a medal's photos
- **WHEN** a user removes a medal's cover photo or any of its event photos and the medal
  save succeeds
- **THEN** the system deletes each removed photo from storage

#### Scenario: Medal save fails after removing photos
- **WHEN** a user removes a medal's cover or event photos and the medal save fails
- **THEN** the photos stay in storage and the medal still shows them

#### Scenario: Delete a medal
- **WHEN** a user deletes a medal and the delete succeeds
- **THEN** the system deletes its cover photo and every event photo from storage; if the
  delete fails, the medal and all its photos remain

### Requirement: Event Photo Gallery
The system SHALL allow a medal to have zero or more additional event photos, separate
from its single cover photo.

#### Scenario: Add event photos to a medal
- **WHEN** a user adds one or more event photos to a medal
- **THEN** the system stores them as an ordered list on that medal, distinct from the
  medal's cover photo

