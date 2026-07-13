# medals Specification

## Purpose
TBD - created by archiving change baseline-current-capabilities. Update Purpose after archive.
## Requirements
### Requirement: Medal Record Management
The system SHALL allow a signed-in user to create, read, update, and delete a `Medal`
record, scoped to that user only, recording race name, date, bib number, location,
distance, optional finish time, optional overall/division/gender placements, optional
division (gender + age group), optional notes, tags, an optional cover photo, and an
event photo gallery.

#### Scenario: Create a medal
- **WHEN** a user submits a new medal with a race name, date, bib number, location,
  and distance
- **THEN** the system creates a `Medal` record under that user's medals

#### Scenario: Medals are private to their owner
- **WHEN** any user's medal list is fetched
- **THEN** the system only returns medals belonging to the requesting user's uid

### Requirement: Event Photo Gallery
The system SHALL allow a medal to have zero or more additional event photos, separate
from its single cover photo.

#### Scenario: Add event photos to a medal
- **WHEN** a user adds one or more event photos to a medal
- **THEN** the system stores them as an ordered list on that medal, distinct from the
  medal's cover photo

