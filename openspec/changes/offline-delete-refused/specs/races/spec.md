## ADDED Requirements

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
