## ADDED Requirements

### Requirement: Editable Profile
The system SHALL allow a signed-in user to view and edit their profile: first name,
last name, photo, bio, gender, and birthday.

#### Scenario: Edit profile fields
- **WHEN** a user updates their first name, last name, bio, gender, or birthday and
  saves
- **THEN** the system persists the updated `User` record

#### Scenario: Display name fallback
- **WHEN** a user has no first or last name set
- **THEN** the system displays "Runner" as their name

### Requirement: Computed Race Statistics
The system SHALL compute and display, from the user's medal list, the total number of
medals, the count of full and half marathon medals, and the best (lowest) finish time
recorded for full and half marathon distances.

#### Scenario: Stats update as medals change
- **WHEN** a user adds or deletes a medal with a full or half marathon distance
- **THEN** the displayed total medal count, distance counts, and best times reflect
  the change without being separately stored on the `User` record
