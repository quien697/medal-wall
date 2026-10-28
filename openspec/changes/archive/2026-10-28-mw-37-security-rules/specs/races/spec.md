## MODIFIED Requirements

### Requirement: Race Management
The system SHALL allow any signed-in user to create and read a `Race`, identified by name,
place, an optional photo, and an optional website URL, and SHALL record the uid of the user who
creates it as its `createdBy`. Only the race's creator, the signed-in user whose uid equals its
`createdBy`, SHALL update or delete it. Race Detail SHALL show its menu of Edit Race and Delete
Race to the creator alone; anyone else SHALL see no such menu. The Races list SHALL NOT offer
to delete a race. A race's place SHALL follow the shape defined by the `place-entry`
capability, which owns the representation of a place and how one is chosen.

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
- **THEN** the system creates a `Race` record with that user as its creator, and it appears in
  the race list

#### Scenario: The creator opens their race
- **WHEN** the user who created a race opens its Race Detail
- **THEN** its menu offers Edit Race and Delete Race

#### Scenario: Another user opens the race
- **WHEN** a user opens Race Detail for a race another user created
- **THEN** no menu offering Edit Race or Delete Race shows, and the race and its editions show
  as they do for its creator

#### Scenario: The Races list does not delete
- **WHEN** a user swipes a race in the Races list
- **THEN** no delete action is offered

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

### Requirement: Race Edition Management
The system SHALL allow any signed-in user to read the `RaceEdition`s belonging to a `Race`, and
only the race's creator to create, update, and delete them. An edition records a year, a start
date, an end date, an optional photo, and a list of distances offered for that edition.
Editions SHALL be added, edited and deleted only from Edit Race, which only the race's creator
can open. The year SHALL be a Gregorian year, and the span of dates it allows SHALL be that
Gregorian year, whatever calendar the device uses, because editions are shared with other users
and clients.

#### Scenario: Add an edition to a race
- **WHEN** a race's creator adds an edition with a year, start date, end date, and at least
  one distance to that race
- **THEN** the system creates a `RaceEdition` in that race's editions subcollection

#### Scenario: One-day edition display
- **WHEN** an edition's start date and end date fall on the same calendar day
- **THEN** the system displays a single date rather than a date range

#### Scenario: Device set to another calendar
- **WHEN** a user whose device uses the Republic of China (民國) calendar adds an edition for
  2026
- **THEN** the edition is saved with the year 2026 and dates within 2026, not the year 115

### Requirement: Offline Race Delete Is Refused
Before deleting a race from Race Detail, the system SHALL check for a connection. Without one,
the delete SHALL be refused with "No internet connection" before anything is deleted, and Race
Detail SHALL stay open.

#### Scenario: Delete a race from Race Detail while offline
- **WHEN** a user confirms deleting a race from Race Detail with no connection
- **THEN** "No internet connection" is shown, nothing is deleted, and Race Detail stays open
