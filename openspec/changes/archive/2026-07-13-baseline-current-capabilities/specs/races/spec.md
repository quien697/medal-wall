## ADDED Requirements

### Requirement: Race Management
The system SHALL allow a signed-in user to create, read, update, and delete a `Race`,
identified by name, location (country, optional province, city, optional district),
an optional photo, and an optional website URL.

#### Scenario: Create a race
- **WHEN** a user submits a new race with a name and location
- **THEN** the system creates a `Race` record and it appears in the race list

#### Scenario: Delete a race removes its editions
- **WHEN** a user deletes a race that has one or more editions
- **THEN** the system deletes all of that race's editions before deleting the race
  itself, since Firestore does not cascade-delete subcollections

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
