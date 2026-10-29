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
subcollections. A race holds at most 200 editions (Edition Limit), so the editions and the race
document SHALL be deleted in one commit, all or nothing. Deleting a race that is already gone
SHALL succeed.

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
- **WHEN** a user deletes a race that has between one and 200 editions
- **THEN** the system deletes all of that race's editions and the race itself in a single
  batched commit, since Firestore does not cascade-delete subcollections

#### Scenario: A race deletion fails partway
- **WHEN** the commit deleting a race is rejected
- **THEN** the race and every one of its editions remain, and the user is shown a delete
  error rather than a race left without some of its editions

#### Scenario: Deleting a race already deleted elsewhere
- **WHEN** a race's creator deletes it from Race Detail after another of their devices has
  already deleted it
- **THEN** the delete succeeds and Race Detail closes, with no delete error

#### Scenario: Delete a race removes its logos
- **WHEN** a user deletes a race and the delete succeeds
- **THEN** the system deletes the race's logo and every edition's logo from storage; if the
  delete fails, every logo remains

#### Scenario: Remove or replace a race or edition logo
- **WHEN** a user removes or replaces a race's logo or an edition's logo, or deletes an
  edition, and the race save succeeds
- **THEN** the system deletes the old logo from storage; if the save fails, the old logo
  remains and any logo uploaded for the save is deleted

### Requirement: Edition Count Integrity
`Race.editionCount` SHALL be maintained only by the operations that create and delete
editions, and each count change SHALL be committed in the same batch as the edition write it
describes. An update to a race's own fields MUST NOT write `editionCount`, because a client
editing a name holds only the count it happened to read earlier, and races are a shared,
globally readable collection whose count another client may have changed since. An update to
an edition MUST NOT be committed with a count change.

A count read back from Firestore SHALL be clamped to zero or more before it is displayed, so
that a value corrupted by any means cannot present a negative number of editions.

#### Scenario: Adding an edition
- **WHEN** a user adds an edition to a race
- **THEN** the edition document and the incremented count commit together, and a failure of
  either leaves both unchanged

#### Scenario: Deleting an edition
- **WHEN** a user deletes an edition from a race
- **THEN** the edition document and the decremented count commit together, and a failure of
  either leaves both unchanged

#### Scenario: Editing a race while another client adds an edition
- **WHEN** a user saves an edit to a race's name, place, photo, or website URL
- **THEN** the write does not include `editionCount`, and a count incremented by another
  client in the meantime survives the edit

#### Scenario: An edition update carries a count change
- **WHEN** a client commits a write to an existing edition together with a change to its
  race's `editionCount`, such as a retried add of an edition that already exists
- **THEN** the backend refuses the commit, and neither the edition nor the count changes

#### Scenario: A stored count is negative
- **WHEN** a race is read whose stored `editionCount` is below zero
- **THEN** the race list displays `0 editions`

## ADDED Requirements

### Requirement: Edition Limit
A race SHALL hold at most 200 editions. Edit Race SHALL disable Add in its Editions section
once the race's editions, counting staged additions and deletions, reach 200, and SHALL then
show the note "A race can have up to 200 editions." Before the race's editions have loaded,
the race's stored edition count SHALL stand in for them. The backend SHALL refuse an edition
that would take a race past 200, whichever client sends it.

#### Scenario: A race at the limit
- **WHEN** a race's creator opens Edit Race for a race with 200 editions
- **THEN** Add in the Editions section is disabled and the note shows

#### Scenario: Staging a delete frees a place
- **WHEN** the creator deletes one edition in Edit Race of a race with 200 editions, before
  saving
- **THEN** Add is enabled again and the note no longer shows

#### Scenario: Before the editions load
- **WHEN** Edit Race opens for a race whose stored count is 200 and its editions are still
  loading
- **THEN** Add is disabled

#### Scenario: Another client adds past the limit
- **WHEN** any client commits an edition that would take a race to 201 editions
- **THEN** the backend refuses the commit, and neither the edition nor the count changes

### Requirement: Shared Race Data Stays Readable
Races and editions are shared with every user, and the app reads a race list or an edition
list in one piece, so one unreadable document hides the whole list. The backend SHALL refuse a
race or edition write that leaves out a field the app needs to read it, or stores one with the
wrong type: for a race its name (not blank), place, edition count, creator and dates; for an
edition its year, start and end dates, race, creator and distances. An optional photo or
website URL SHALL be absent, null, or text.

#### Scenario: A race without a name
- **WHEN** any client creates a race with no `name`, or with a blank one
- **THEN** the backend refuses it, and the Races list and Search still load for everyone

#### Scenario: An edition with a date stored as text
- **WHEN** any client writes an edition whose `startDate` is text rather than a timestamp
- **THEN** the backend refuses it, and the race's editions still load
