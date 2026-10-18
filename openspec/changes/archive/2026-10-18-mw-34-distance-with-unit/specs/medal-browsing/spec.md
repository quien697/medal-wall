## MODIFIED Requirements

### Requirement: Distance Filtering
The system SHALL offer a distance filter whose options are derived from the distance
categories present in the user's collection, never from a fixed list. The options SHALL be
an `All` option first, followed by one option per distance category the user owns, ordered
by real length from longest to shortest. Each option SHALL carry the number of medals it
selects. Selecting an option SHALL narrow the presented medals to that distance category;
selecting `All` SHALL present every medal.

A distance category SHALL be identified by its exact stored value and unit. No distance is
folded into a nearby one, so `10K` and `10 mi` are separate options, and a medal at `42.2`
kilometres has its own option rather than joining `Full`.

#### Scenario: Options reflect what the user owns
- **WHEN** a collection contains only half marathons and 10K races
- **THEN** the filter offers `All`, `Half`, and `10K`, and offers no option for full
  marathons or 5K races

#### Scenario: Options are ordered longest first
- **WHEN** a collection contains 5K, full marathon, and half marathon medals
- **THEN** the filter offers `All`, then `Full`, then `Half`, then `5K`

#### Scenario: Custom distances appear as options
- **WHEN** a collection contains a medal at a custom distance
- **THEN** that custom distance is offered as its own filter option, placed among the
  others by its real length

#### Scenario: The same number in different units are separate options
- **WHEN** a collection contains a 10K medal and a `10 mi` medal
- **THEN** the filter offers `10 mi` and `10K` as separate options, `10 mi` first because it
  is longer

#### Scenario: A near-standard distance is its own option
- **WHEN** a collection contains a full marathon medal and a medal at `42.2` kilometres
- **THEN** the filter offers `42.2 km` and `Full` as separate options, each counting one
  medal

#### Scenario: Each option reports its own count
- **WHEN** a collection contains nine medals, five full marathons and four half marathons
- **THEN** the `All` option reports nine, the `Full` option reports five, and the `Half`
  option reports four

#### Scenario: Selecting a distance narrows the list
- **WHEN** the user selects the `Half` option
- **THEN** the list presents only half marathon medals, and the year groups and their
  counts describe only those medals

### Requirement: Personal Record Derivation
The system SHALL derive a personal record for each distance category as the fastest finish
time recorded at that distance. A personal record SHALL NOT be persisted — it is computed
from the collection on demand, so adding, editing, or deleting a medal moves it without any
stored value going stale.

A medal SHALL be eligible for a personal record only if it records a finish time greater
than zero. A medal with no finish time SHALL be excluded. A non-positive finish time SHALL
be excluded rather than treated as the fastest, so a corrupt or malicious stored value
cannot claim the record.

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

#### Scenario: A tie is broken by the earlier date
- **WHEN** two medals in a category share the fastest finish time
- **THEN** the earlier-dated medal is marked, and the later one is not

#### Scenario: Filtering does not move a record
- **WHEN** the user selects a distance filter
- **THEN** the medal marked in that category is the same medal marked when `All` is
  selected
