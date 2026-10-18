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
optional photo, and a list of distances offered for that edition. The year SHALL be a
Gregorian year, and the span of dates it allows SHALL be that Gregorian year, whatever
calendar the device uses, because editions are shared with other users and clients.

#### Scenario: Add an edition to a race
- **WHEN** a user adds an edition with a year, start date, end date, and at least one
  distance to an existing race
- **THEN** the system creates a `RaceEdition` in that race's editions subcollection

#### Scenario: One-day edition display
- **WHEN** an edition's start date and end date fall on the same calendar day
- **THEN** the system displays a single date rather than a date range

#### Scenario: Device set to another calendar
- **WHEN** a user whose device uses the Republic of China (民國) calendar adds an edition for
  2026
- **THEN** the edition is saved with the year 2026 and dates within 2026, not the year 115

### Requirement: Preset And Custom Distances Coexist
The system SHALL NOT snap a custom distance to a nearby standard distance, and SHALL NOT
prompt the user to confirm whether a near-standard value was meant as a standard one. A
custom `42` km and a Full Marathon are therefore distinct distances that can both appear in
one edition. The edition's duplicate check SHALL compare the exact value, unit and race
type, so `10K` and a custom `10 mi` of the same type can both appear, while the same value
and unit twice cannot. The distance picker SHALL instead show each preset's stored
measurement, identical in both units, so a user looking for a known number finds it on the
preset row rather than typing it into the custom field.

#### Scenario: Preset rows show their measurement
- **WHEN** a user opens the distance picker, with the distance unit set to either
  Kilometers or Miles
- **THEN** the preset rows read `Full Marathon · 42.195 km`, `Half Marathon · 21.0975 km`,
  `10K · 10 km`, and `5K · 5 km`

#### Scenario: A near-preset custom distance is not snapped
- **WHEN** a user enters a custom distance of `26.2` miles rather than selecting the Full
  Marathon preset
- **THEN** the distance is stored as `26.2` miles and remains a custom distance, with no
  prompt and no conversion to the preset

#### Scenario: The same number in another unit is not a duplicate
- **WHEN** an edition already offers an in-person `10K` and a user adds an in-person custom
  `10 mi`
- **THEN** both distances are kept

#### Scenario: The same value and unit is a duplicate
- **WHEN** an edition already offers an in-person `10K` and a user adds an in-person custom
  `10` kilometres
- **THEN** it is refused as a duplicate distance

### Requirement: Offline Race Delete Is Refused
Before deleting a race, from Race Detail or the Races list, the system SHALL check for a
connection. Without one, the delete SHALL be refused with "No internet connection" before
anything is deleted, and the race SHALL stay where it is.

#### Scenario: Delete a race from Race Detail while offline
- **WHEN** a user confirms deleting a race from Race Detail with no connection
- **THEN** "No internet connection" is shown, nothing is deleted, and Race Detail stays open

#### Scenario: Delete a race from the Races list while offline
- **WHEN** a user confirms deleting a race from the Races list with no connection
- **THEN** "No internet connection" is shown, nothing is deleted, and the race stays in the list

### Requirement: Custom Distance Entry With Its Own Unit
The system SHALL accept a custom distance as a number together with a unit chosen by a
Kilometers / Miles switch beside the field. For a new custom distance the switch SHALL start
at the distance unit setting; for a stored custom distance it SHALL start at the stored
unit. The distance SHALL be stored with the number and unit as entered, with no conversion,
so opening and saving a distance without editing it never changes it.

A custom distance SHALL be greater than zero, less than 10,000 in its own unit, and have at
most four decimal places; any other value SHALL be refused with the invalid distance error. A
number and unit equal to a standard distance SHALL be saved as that standard distance.

#### Scenario: Entering a custom distance in miles
- **WHEN** a user sets the switch to Miles and enters a custom distance of `10`
- **THEN** the distance is stored as `10` miles and reads `10 mi`

#### Scenario: The switch starts at the distance unit setting
- **WHEN** the distance unit is Miles and a user chooses Custom for a new distance
- **THEN** the switch shows Miles

#### Scenario: A stored custom distance opens in its own unit
- **WHEN** the distance unit is Miles and a user opens a custom distance stored as `42.2`
  kilometres
- **THEN** the field shows `42.2` and the switch shows Kilometers, and saving without an
  edit leaves it stored as `42.2` kilometres

#### Scenario: More than four decimals is refused
- **WHEN** a user enters a custom distance of `10.12345`
- **THEN** it is refused with the invalid distance error and nothing is saved

#### Scenario: Zero is refused
- **WHEN** a user enters a custom distance of `0`
- **THEN** it is refused with the invalid distance error and nothing is saved

#### Scenario: 10,000 or more is refused
- **WHEN** a user enters a custom distance of `10000` in either unit
- **THEN** it is refused with the invalid distance error and nothing is saved

#### Scenario: A standard value saves the standard distance
- **WHEN** a user enters a custom distance of `42.195` with the switch at Kilometers
- **THEN** it is saved as the Full Marathon and reads `Full`

