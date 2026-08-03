## MODIFIED Requirements

### Requirement: Race Management
The system SHALL allow a signed-in user to create, read, update, and delete a `Race`,
identified by name, location, an optional photo, and an optional website URL. A race's
location SHALL follow the shape defined by the `location-entry` capability, which owns the
representation of a location and how one is chosen.

#### Scenario: Create a race
- **WHEN** a user submits a new race with a name and location
- **THEN** the system creates a `Race` record and it appears in the race list

#### Scenario: Delete a race removes its editions
- **WHEN** a user deletes a race that has one or more editions
- **THEN** the system deletes all of that race's editions before deleting the race
  itself, since Firestore does not cascade-delete subcollections
