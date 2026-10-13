## MODIFIED Requirements

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
