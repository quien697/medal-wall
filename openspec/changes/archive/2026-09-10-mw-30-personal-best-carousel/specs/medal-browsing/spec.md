## ADDED Requirements

### Requirement: Personal Best Presentation
The system SHALL present the derived personal records directly, at the top of the
collection screen, rather than only marking the medals that hold them.

Each distance category holding a personal record SHALL be presented as its own entry.
Entries SHALL be ordered by distance, longest first, matching the order the distance
filter presents its options.

A distance category holding no personal record — because it has no medal with an eligible
finish time — SHALL contribute no entry. Where the collection holds no personal record at
all, the system SHALL present nothing in place of the entries: no entry, no placeholder,
and no empty state of its own.

An entry's identity SHALL be its distance category rather than the medal holding the
record, so an entry keeps its position when a faster medal takes its record over.

#### Scenario: One entry per distance holding a record
- **WHEN** a collection holds records at the full, half, and 10K distances
- **THEN** three entries are presented, one per distance

#### Scenario: Entries are ordered longest distance first
- **WHEN** a collection holds records at the half and full distances
- **THEN** the full marathon entry is presented before the half marathon entry

#### Scenario: A distance with no eligible time contributes no entry
- **WHEN** every 10K medal in the collection records no finish time
- **THEN** no 10K entry is presented, while entries for distances that do hold records
  are presented as normal

#### Scenario: A collection with no records presents nothing
- **WHEN** no medal in the collection records an eligible finish time
- **THEN** no entries are presented at all, and the distance filter and the list are
  presented as they otherwise would be

#### Scenario: An entry survives its record changing hands
- **WHEN** a faster medal is added at a distance that already held a record
- **THEN** that distance's entry presents the new record without changing position among
  the entries

### Requirement: Personal Best Content
Each personal best entry SHALL state which distance it describes, the record finish time,
the race the record was set at, and the average pace that time represents. The pace SHALL
be expressed in the user's chosen distance unit, consistent with every other distance the
app presents.

Each entry SHALL carry the same earned marker the record-holding medal's row carries, so
the marker means one thing across the screen.

#### Scenario: An entry states its record
- **WHEN** the full marathon record is 03:30:24, set at Taipei Marathon 2019
- **THEN** its entry presents the full marathon distance, the time 03:30:24, the race name
  Taipei Marathon 2019, and the pace that time represents

#### Scenario: Pace follows the distance unit preference
- **WHEN** the user's distance unit preference is miles
- **THEN** the entry presents its pace per mile rather than per kilometre

#### Scenario: An entry carries the earned marker
- **WHEN** an entry presents a personal record
- **THEN** it shows the same record marker the holding medal's row shows

### Requirement: Personal Best Presentation Is Independent Of The Distance Filter
The personal best entries SHALL describe the whole collection at all times. Selecting a
distance filter SHALL NOT change which entries are presented, and moving between entries
SHALL NOT change the distance filter selection or the medals the list presents.

#### Scenario: Filtering does not reduce the entries
- **WHEN** the user selects the half marathon distance filter
- **THEN** every entry presented under `All` is still presented, in the same order

#### Scenario: Moving between entries does not filter the list
- **WHEN** the user moves from the full marathon entry to the half marathon entry
- **THEN** the distance filter selection is unchanged and the list presents the same
  medals as before

### Requirement: Navigating From A Personal Best
The system SHALL let the user open the medal holding a record from its entry, arriving at
the same medal detail the collection list leads to.

#### Scenario: An entry opens its medal
- **WHEN** the user selects the full marathon entry
- **THEN** the detail for the medal holding the full marathon record is presented

#### Scenario: An entry reaches a medal the filter hides
- **WHEN** the distance filter is narrowed so the record-holding medal's row is not
  presented in the list
- **THEN** selecting that distance's entry still opens that medal's detail

### Requirement: Multiple Personal Bests Are Discoverable
Where more than one personal best entry exists, the system SHALL indicate how many there
are and which one is currently presented, because one entry occupies the full width and
leaves no part of the next one visible.

Where exactly one entry exists, the system SHALL present no such indicator, so a single
record carries no suggestion that something is hidden.

#### Scenario: Several entries are indicated
- **WHEN** three personal best entries exist
- **THEN** an indicator presents three positions with the current entry's position
  distinguished

#### Scenario: A single entry shows no indicator
- **WHEN** exactly one personal best entry exists
- **THEN** no position indicator is presented

#### Scenario: The indicator follows the presented entry
- **WHEN** the user moves from the first entry to the second
- **THEN** the indicator distinguishes the second position
