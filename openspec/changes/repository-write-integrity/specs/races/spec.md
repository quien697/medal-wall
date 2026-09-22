## ADDED Requirements

### Requirement: Edition Count Integrity
`Race.editionCount` SHALL be maintained only by the operations that create and delete
editions, and each count change SHALL be committed in the same batch as the edition write it
describes. An update to a race's own fields MUST NOT write `editionCount`, because a client
editing a name holds only the count it happened to read earlier, and races are a shared,
globally readable collection whose count another client may have changed since.

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

#### Scenario: A stored count is negative
- **WHEN** a race is read whose stored `editionCount` is below zero
- **THEN** the race list displays `0 editions`

## MODIFIED Requirements

### Requirement: Race Management
The system SHALL allow a signed-in user to create, read, update, and delete a `Race`,
identified by name, place, an optional photo, and an optional website URL. A race's place
SHALL follow the shape defined by the `place-entry` capability, which owns the representation
of a place and how one is chosen.

#### Scenario: Create a race
- **WHEN** a user submits a new race with a name and place
- **THEN** the system creates a `Race` record and it appears in the race list

#### Scenario: Delete a race removes its editions
- **WHEN** a user deletes a race that has one or more editions
- **THEN** the system deletes all of that race's editions and the race itself in a single
  batched commit, since Firestore does not cascade-delete subcollections

#### Scenario: A race deletion fails partway
- **WHEN** the commit deleting a race and its editions is rejected
- **THEN** the race and every one of its editions remain, and the user is shown a delete
  error rather than a race left without some of its editions
