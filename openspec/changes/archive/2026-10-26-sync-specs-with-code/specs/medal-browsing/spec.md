## MODIFIED Requirements

### Requirement: Personal Record Derivation
The system SHALL derive a personal record for each distance category as the fastest finish
time recorded at that distance. A personal record SHALL NOT be persisted — it is computed
from the collection on demand, so adding, editing, or deleting a medal moves it without any
stored value going stale.

A medal SHALL be eligible for a personal record only if it has a recorded finish time, as
the `medals` capability defines one, and its distance is a positive, finite number. Any other
medal SHALL be excluded rather than treated as the fastest, so a corrupt or malicious stored
value cannot claim the record.

Where two eligible medals in a category share the fastest time, the earlier-dated medal
SHALL hold the record, so exactly one medal per category is marked.

The system SHALL derive personal records from the user's whole collection, not from the
currently filtered subset, so a filter selection never changes which medal holds a record.

#### Scenario: Fastest time in a category holds the record
- **WHEN** a collection contains half marathons at 01:48:52 and 01:52:40
- **THEN** the 01:48:52 medal is marked as the personal record for the half marathon

#### Scenario: Each category holds its own record
- **WHEN** a collection contains both full and half marathons with finish times
- **THEN** one full marathon medal and one half marathon medal are each marked

#### Scenario: The same number in different units holds separate records
- **WHEN** a collection contains a 10K medal and a `10 mi` medal, both with finish times
- **THEN** each is marked as the personal record for its own distance

#### Scenario: Medals without a finish time are excluded
- **WHEN** the only medal in a category has no finish time
- **THEN** no medal in that category is marked as a personal record

#### Scenario: A non-positive finish time cannot hold the record
- **WHEN** a category contains a medal with a stored finish time of zero or less
  alongside a medal with a valid finish time
- **THEN** the medal with the valid finish time holds the record

#### Scenario: A distance that is not a positive number cannot hold the record
- **WHEN** a medal with a valid finish time has a stored distance of zero, below zero,
  infinite or not a number
- **THEN** it does not hold a personal record

#### Scenario: A tie is broken by the earlier date
- **WHEN** two medals in a category share the fastest finish time
- **THEN** the earlier-dated medal is marked, and the later one is not

#### Scenario: Filtering does not move a record
- **WHEN** the user selects a distance filter
- **THEN** the medal marked in that category is the same medal marked when `All` is
  selected
