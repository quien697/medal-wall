# races Specification

## Purpose
Let a signed-in user manage races and their per-year editions — full CRUD over `Race`
and its `RaceEdition` subcollection — including manually cascading edition deletes, since
Firestore does not cascade-delete subcollections.
## Requirements
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

### Requirement: Race Edition Management
The system SHALL allow a signed-in user to create, read, update, and delete a
`RaceEdition` belonging to a `Race`, recording a year, a start date, an end date, an
optional photo, and a list of distances offered for that edition.

#### Scenario: Add an edition to a race
- **WHEN** a user adds an edition with a year, start date, end date, and at least one
  distance to an existing race
- **THEN** the system creates a `RaceEdition` in that race's editions subcollection

#### Scenario: One-day edition display
- **WHEN** an edition's start date and end date fall on the same calendar day
- **THEN** the system displays a single date rather than a date range

### Requirement: Custom Distance Entry In The Active Unit
The system SHALL accept a custom race distance in the user's active distance unit, label
the input field with that unit, and convert to kilometres at full precision for storage —
so a distance entered as 10 miles is stored as `16.09344` kilometres and reads back as
exactly 10 miles.

Where a stored distance is opened for editing under a different unit than it was entered
in, the displayed value is rounded for legibility. If the user does not edit the field,
the system SHALL save the original stored value unchanged rather than re-converting the
rounded display value. Race editions are shared, globally readable records, and a no-op
edit MUST NOT silently alter one.

#### Scenario: Entering a custom distance in miles
- **WHEN** the active unit is miles and a user enters a custom distance of `10`
- **THEN** the field is labelled `Custom distance (mi)` and the value is stored as
  `16.09344` kilometres

#### Scenario: Round-tripping a mile-entered distance
- **WHEN** a distance stored as `16.09344` kilometres is viewed in miles
- **THEN** it displays as `10 mi`

#### Scenario: Saving an unedited custom distance under a different unit
- **WHEN** a distance stored as `16.09` kilometres is opened for editing in miles mode,
  displaying a rounded `10`, and the user saves without editing the field
- **THEN** the stored value remains `16.09` kilometres

#### Scenario: Editing a custom distance under a different unit
- **WHEN** that same distance is opened in miles mode and the user changes the field
  to `12`
- **THEN** the stored value becomes `19.312128` kilometres

### Requirement: Preset And Custom Distances Coexist
The system SHALL NOT snap a custom distance to a nearby preset, and SHALL NOT prompt the
user to confirm whether a near-preset value was meant as a preset. A custom `42` km and a
Full Marathon are therefore distinct distances that can both appear in one edition, since
the duplicate guard compares stored kilometre values exactly. The distance picker SHALL
instead show each preset's measurement in the active unit, so a user looking for a known
number finds it on the preset row rather than typing it into the custom field.

#### Scenario: Preset rows show their measurement
- **WHEN** the active unit is miles and a user opens the distance picker
- **THEN** the preset rows read `Full Marathon · 26.2 mi`, `Half Marathon · 13.1 mi`,
  `10K · 6.2 mi`, and `5K · 3.1 mi`

#### Scenario: A near-preset custom distance is not snapped
- **WHEN** a user enters a custom distance of `26.2` miles rather than selecting the Full
  Marathon preset
- **THEN** the distance is stored as `42.1648128` kilometres and remains a custom distance,
  with no prompt and no conversion to the preset
