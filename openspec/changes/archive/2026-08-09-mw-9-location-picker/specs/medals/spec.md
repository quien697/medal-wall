## MODIFIED Requirements

### Requirement: Medal Record Management
The system SHALL allow a signed-in user to create, read, update, and delete a `Medal`
record, scoped to that user only, recording race name, date, bib number, place,
distance, optional finish time, optional overall/division/gender placements, optional
division (gender + age group), optional notes, tags, an optional cover photo, and an
event photo gallery. A medal's place SHALL follow the shape defined by the `place-entry`
capability, which owns the representation of a place and how one is chosen.

#### Scenario: Create a medal
- **WHEN** a user submits a new medal with a race name, date, bib number, place,
  and distance
- **THEN** the system creates a `Medal` record under that user's medals

#### Scenario: Medals are private to their owner
- **WHEN** any user's medal list is fetched
- **THEN** the system only returns medals belonging to the requesting user's uid
