## ADDED Requirements

### Requirement: Deterministic Collection Ordering
The system SHALL present a user's medals in a deterministic order that does not depend on
the order Firestore returns documents. Medals SHALL be ordered by date, most recent first.
Two medals sharing a date SHALL be ordered by their identifier so the sequence is stable
across launches.

#### Scenario: Order does not depend on fetch order
- **WHEN** the same set of medals is fetched twice and returned in different document
  orders
- **THEN** the list presents them in the same order both times

#### Scenario: Most recent medal appears first
- **WHEN** a collection contains medals dated 2019, 2022, and 2025
- **THEN** the 2025 medal is presented before the 2022 medal, which is presented before
  the 2019 medal

### Requirement: Year Grouping
The system SHALL group the presented medals by the calendar year of each medal's date,
with the most recent year first. Each group SHALL carry a header showing the year and the
number of medals in that group. A year with no medals in the presented set SHALL NOT
produce a group, so the list never shows an empty year.

#### Scenario: Medals are grouped under their year
- **WHEN** a collection contains one medal from 2025 and two from 2022
- **THEN** the list shows a 2025 group containing one medal, followed by a 2022 group
  containing two medals

#### Scenario: Gap years are omitted
- **WHEN** a collection contains medals from 2025 and 2019 but none from the years between
- **THEN** the list shows exactly two groups, 2025 and 2019, with nothing between them

#### Scenario: Group header reports its count
- **WHEN** a year group contains two medals
- **THEN** its header reads the year and a count of two medals, pluralized for the count
  it reports

### Requirement: Distance Filtering
The system SHALL offer a distance filter whose options are derived from the distance
categories present in the user's collection, never from a fixed list. The options SHALL be
an `All` option first, followed by one option per distance category the user owns, ordered
by distance from longest to shortest. Each option SHALL carry the number of medals it
selects. Selecting an option SHALL narrow the presented medals to that distance category;
selecting `All` SHALL present every medal.

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
  others by its distance

#### Scenario: Each option reports its own count
- **WHEN** a collection contains nine medals, five full marathons and four half marathons
- **THEN** the `All` option reports nine, the `Full` option reports five, and the `Half`
  option reports four

#### Scenario: Selecting a distance narrows the list
- **WHEN** the user selects the `Half` option
- **THEN** the list presents only half marathon medals, and the year groups and their
  counts describe only those medals

### Requirement: Filter Selection Survives a Changed Collection
The collection can change underneath a selection: a medal can be deleted or have its
distance edited elsewhere in the app, and the list reloads when the user returns. Where the
selected distance category is no longer present in the collection, the system SHALL fall
back to `All` rather than presenting an empty list or an option that selects nothing.

#### Scenario: The selected category disappears
- **WHEN** the user has selected `10K` and then deletes their only 10K medal
- **THEN** on returning to the list the selection falls back to `All` and every remaining
  medal is presented

#### Scenario: A surviving selection is kept
- **WHEN** the user has selected `Half` and deletes a full marathon medal
- **THEN** the selection remains `Half` and the list continues to present half marathons

### Requirement: A Filter Selection Always Has Results
Because filter options are derived from the categories the user owns, every offered option
SHALL select at least one medal. The system SHALL therefore have exactly one empty state on
this screen: a collection containing no medals at all.

#### Scenario: No offered filter yields an empty list
- **WHEN** the user selects any option the filter offers
- **THEN** the list presents at least one medal

#### Scenario: An empty collection shows the empty state
- **WHEN** a user has no medals
- **THEN** the screen shows the empty state and offers no filter options

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

### Requirement: Personal Record Marking
The system SHALL mark the medal holding a personal record with the design system's earned
treatment, reserved for records and used for nothing else on this screen.

#### Scenario: The record-holding medal is marked
- **WHEN** a medal holds the personal record for its distance category
- **THEN** its row shows the record marker beside its finish time

#### Scenario: Other medals are unmarked
- **WHEN** a medal does not hold the personal record for its distance category
- **THEN** its row shows its finish time with no record marker

### Requirement: Medals Without a Finish Time
The system SHALL present a medal that records no finish time as explicitly untimed rather
than showing a placeholder character, so an unrecorded result is not mistaken for a missing
one.

#### Scenario: An untimed medal states that it is untimed
- **WHEN** a medal has no finish time
- **THEN** its row reads that no time was recorded, in place of a finish time

#### Scenario: An untimed medal still appears in its year and filter
- **WHEN** a medal has no finish time
- **THEN** it appears in its year group and is counted by its distance filter option, the
  same as a timed medal
