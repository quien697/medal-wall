# distance-units Specification

## Purpose
Own how a distance is stored and how it reads on screen: a distance keeps the number and
unit it was entered in, a standard distance is named and any other shows its stored
measurement, and nothing is converted for display. Also own the distance unit preference and
how the device seeds it, and pace, which is expressed per unit of that preference.
## Requirements
### Requirement: Distance Unit Resolution
The system SHALL offer exactly two distance unit options — Kilometers and Miles. Until the
user has chosen one, the app SHALL derive the unit from the **device region's** measurement
system rather than from the app's language preference. A pinned app language carries no
region, so it MUST NOT be used to infer a measurement system. All three measurement systems
SHALL be handled explicitly: metric derives kilometres, US derives miles, and UK derives
miles.

Once the user chooses, a **concrete** unit SHALL be stored. The system SHALL NOT persist a
"follow the device" sentinel, so a stored preference means the same thing on every device
and on every client that may later read it.

#### Scenario: Derives kilometres in a metric region before any choice
- **WHEN** the user has never chosen a unit and the device region uses the metric
  measurement system (e.g. Canada, Taiwan)
- **THEN** the distance unit resolves to Kilometers

#### Scenario: Derives miles in the US before any choice
- **WHEN** the user has never chosen a unit and the device region uses the US measurement
  system
- **THEN** the distance unit resolves to Miles, without the user opening Settings

#### Scenario: Derives miles in the UK before any choice
- **WHEN** the user has never chosen a unit and the device region uses the UK measurement
  system
- **THEN** the distance unit resolves to Miles, matching UK road-running convention

#### Scenario: An explicit choice outranks the device
- **WHEN** a user in a metric region selects Miles
- **THEN** the distance unit resolves to Miles, and continues to do so regardless of the
  device region

#### Scenario: Only a concrete unit is ever stored
- **WHEN** a user selects either option in the distance picker
- **THEN** the persisted value is `kilometers` or `miles` — never a sentinel meaning
  "whatever this device says"

#### Scenario: Language preference does not affect the unit
- **WHEN** the user pins the app language to English while the device region is Taiwan,
  and has not chosen a unit
- **THEN** the distance unit resolves to Kilometers, because the unit follows the device
  region and not the pinned language

### Requirement: Preset Distances Display As Names
The system SHALL render the four standard distances as names rather than numbers, in both
units, because those names are what runners call them. Cards, badges, filter chips and other
compact surfaces SHALL use the short forms `Full`, `Half`, `10K` and `5K`; the distance
picker SHALL use the long forms `Full Marathon` and `Half Marathon` alongside `10K` and
`5K`. All names SHALL be sourced from the String Catalog so they localize (`全馬` / `半馬`
under `zh-TW`). A name SHALL stand for exactly one stored distance, so a distance that only
comes close to a standard one is shown as its measurement.

#### Scenario: Preset names are identical in both units
- **WHEN** a user views a medal card for a full marathon
- **THEN** the badge reads `Full` whether the distance unit resolves to Kilometers or to
  Miles

#### Scenario: Preset names localize
- **WHEN** the app language is 繁體中文 and a user views a full marathon medal card
- **THEN** the badge reads `全馬`

#### Scenario: A near-standard distance is not named
- **WHEN** a user views a medal card for a medal at `42.2` kilometres
- **THEN** the badge reads `42.2 km`, not `Full`

### Requirement: Pace Expressed In The Active Unit
The system SHALL calculate average pace from the recorded finish time and the real length of
the distance, whichever unit the distance is stored in, and SHALL express it per unit of the
active distance unit — minutes per kilometre or minutes per mile. Converting a distance to
its real length is done in memory only and is never shown or stored. Seconds are truncated
rather than rounded, which is the app's existing behaviour.

#### Scenario: Pace in miles
- **WHEN** the active unit is miles and a medal's pace is 5'41" per kilometre
- **THEN** the detail screen shows `9'08" /mi`

#### Scenario: Pace in kilometres
- **WHEN** the active unit is kilometres and a medal's pace is 5'41" per kilometre
- **THEN** the detail screen shows `5'41" /km`

#### Scenario: Pace for a distance stored in miles
- **WHEN** a medal's distance is stored as `10` miles with a finish time of 1:10:00
- **THEN** the pace reads `7'00" /mi` when the active unit is miles, and `4'20" /km` when
  it is kilometres

### Requirement: Distance Stored With Its Unit
The system SHALL store the event a medal was earned in as `raceEvent: { kind, value, unit, type }`,
the events a race edition offers as `raceEvents: [{ kind, value, unit, type }]`, and a medal's
result, when one is recorded, as `result: { value, unit }`. `kind` SHALL be `"distance"`. An
event's `unit` SHALL be `"kilometers"` or `"miles"`, its `type` SHALL be `"inPerson"`,
`"virtual"` or `"wheelChair"`, and a result's `unit` SHALL be `"seconds"`. This is a
cross-platform contract: every client writes these exact spellings.

A distance SHALL be stored with the number and unit it was entered in, and SHALL NOT be
converted to the other unit for storage. The distance unit setting SHALL NOT change what is
written to Firestore.

The four standard distances SHALL be stored as exactly `42.195` (Full), `21.0975` (Half),
`10` (10K) and `5` (5K) kilometres, and SHALL be recognised by exact value and unit. Any
other distance, including every distance in miles, is a custom distance.

#### Scenario: A distance entered in miles is stored in miles
- **WHEN** a user saves an in-person medal at a custom distance of 10 miles
- **THEN** its event is stored as `{ kind: "distance", value: 10, unit: "miles", type: "inPerson" }`

#### Scenario: A finish time is stored in seconds
- **WHEN** a user saves a medal with a finish time of 3:45:00
- **THEN** its result is stored as `{ value: 13500, unit: "seconds" }`

#### Scenario: A medal without a finish time has no result
- **WHEN** a user saves a medal with no finish time
- **THEN** the stored medal has no `result` field

#### Scenario: Changing the unit does not rewrite stored data
- **WHEN** a user switches the distance unit between Kilometers and Miles
- **THEN** no Firestore document is written, and every stored distance is unchanged

#### Scenario: A standard distance is matched exactly
- **WHEN** an event is read with a value of `42.195` and a unit of `kilometers`
- **THEN** it is recognised as the Full Marathon

#### Scenario: A near-standard distance is a custom distance
- **WHEN** an event is read as `42.2` kilometres or as `26.2` miles
- **THEN** it is a custom distance, not the Full Marathon

### Requirement: Stored Measurement Display
The system SHALL display a distance's stored measurement — its stored number with its
stored unit — on the preset rows of the distance picker and for every custom distance
wherever it appears. The measurement SHALL read the same whatever the distance unit
setting, because no distance is converted for display.

Measured values SHALL be formatted with up to four fraction digits and trailing zeros
dropped, using the locale resolved from the app's language preference, and paired with a
String Catalog abbreviation (`km` / `mi`) rather than a Foundation-supplied unit name.

#### Scenario: A distance in miles reads in miles under the kilometre setting
- **WHEN** the distance unit is Kilometers and a medal's distance is stored as `10` miles
- **THEN** it reads `10 mi`

#### Scenario: A distance in kilometres reads in kilometres under the mile setting
- **WHEN** the distance unit is Miles and a medal's distance is stored as `42.2` kilometres
- **THEN** it reads `42.2 km`

#### Scenario: Four decimals are shown
- **WHEN** a custom distance stored as `12.3456` kilometres is displayed
- **THEN** it reads `12.3456 km`

#### Scenario: Trailing zeros are dropped
- **WHEN** a custom distance of exactly `16` kilometres is displayed
- **THEN** it reads `16 km`, not `16.0 km`

