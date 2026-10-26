## MODIFIED Requirements

### Requirement: Race Management
The system SHALL allow a signed-in user to create, read, update, and delete a `Race`,
identified by name, place, an optional photo, and an optional website URL. A race's place
SHALL follow the shape defined by the `place-entry` capability, which owns the representation
of a place and how one is chosen.

Every logo upload SHALL go to a new storage location, never over a file a race or edition
points at. A logo the race no longer holds — a removed or replaced race or edition logo, a
deleted edition's logo, or every logo of a deleted race — SHALL be deleted from storage, and
only after the Firestore write or delete succeeds, so a race or edition never points at a
deleted file. A logo uploaded for a write that fails SHALL be deleted. A logo that fails to
delete is left in storage rather than failing a write. Medals are untouched: they hold no reference to a race.

Deleting a race SHALL delete its editions with it, since Firestore does not cascade-delete
subcollections. Firestore commits at most 500 writes at once, so the editions SHALL be deleted
in batches of up to 499 with the race document in the last batch. A race with up to 499
editions is therefore deleted in one commit, all or nothing; a larger race whose delete fails
partway keeps the race with fewer editions, and never leaves editions under a deleted race.

#### Scenario: Create a race
- **WHEN** a user submits a new race with a name and place
- **THEN** the system creates a `Race` record and it appears in the race list

#### Scenario: Delete a race removes its editions
- **WHEN** a user deletes a race that has between one and 499 editions
- **THEN** the system deletes all of that race's editions and the race itself in a single
  batched commit, since Firestore does not cascade-delete subcollections

#### Scenario: A race deletion fails partway
- **WHEN** the commit deleting a race with up to 499 editions is rejected
- **THEN** the race and every one of its editions remain, and the user is shown a delete
  error rather than a race left without some of its editions

#### Scenario: Deleting a race with 500 or more editions
- **WHEN** a user deletes a race that has 500 or more editions
- **THEN** its editions are deleted in batches of up to 499, the race in the last batch, and a
  delete that fails partway leaves the race in place with fewer editions

#### Scenario: Delete a race removes its logos
- **WHEN** a user deletes a race and the delete succeeds
- **THEN** the system deletes the race's logo and every edition's logo from storage; if the
  delete fails, every logo remains

#### Scenario: Remove or replace a race or edition logo
- **WHEN** a user removes or replaces a race's logo or an edition's logo, or deletes an
  edition, and the race save succeeds
- **THEN** the system deletes the old logo from storage; if the save fails, the old logo
  remains and any logo uploaded for the save is deleted
