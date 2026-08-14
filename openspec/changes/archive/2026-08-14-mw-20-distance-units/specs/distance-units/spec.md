## ADDED Requirements

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
- **THEN** the app displays distances in kilometres

#### Scenario: Derives miles in the US before any choice
- **WHEN** the user has never chosen a unit and the device region uses the US measurement
  system
- **THEN** the app displays distances in miles, without the user opening Settings

#### Scenario: Derives miles in the UK before any choice
- **WHEN** the user has never chosen a unit and the device region uses the UK measurement
  system
- **THEN** the app displays distances in miles, matching UK road-running convention

#### Scenario: An explicit choice outranks the device
- **WHEN** a user in a metric region selects Miles
- **THEN** the app displays miles, and continues to do so regardless of the device region

#### Scenario: Only a concrete unit is ever stored
- **WHEN** a user selects either option in the distance picker
- **THEN** the persisted value is `kilometers` or `miles` — never a sentinel meaning
  "whatever this device says"

#### Scenario: Language preference does not affect the unit
- **WHEN** the user pins the app language to English while the device region is Taiwan,
  and has not chosen a unit
- **THEN** the app displays distances in kilometres, because the unit follows the device
  region and not the pinned language

### Requirement: Kilometre-Canonical Distance Storage
The system SHALL persist every distance value in kilometres. The unit preference is a
display concern only and SHALL NOT change what is written to Firestore, add a unit field
to any persisted model, or alter distance sorting, equality, or hashing.

The four preset distances SHALL be stored as exactly `42.195` (Full), `21.0975` (Half),
`10` (10K), and `5` (5K) kilometres, and SHALL be recognised by exact match on read. Any
other stored value is a custom distance. This is a cross-platform contract: a non-Apple
client that writes a different value — `42.2` rather than `42.195` — produces a custom
distance rather than a Full Marathon.

#### Scenario: Changing the unit does not rewrite stored data
- **WHEN** a user switches the distance unit between Kilometers and Miles
- **THEN** no Firestore document is written, and every stored distance value is unchanged

#### Scenario: Preset values are matched exactly
- **WHEN** a distance is read with a stored value of `42.195`
- **THEN** it is recognised as the Full Marathon preset

#### Scenario: A near-preset value is a custom distance
- **WHEN** a distance is read with a stored value of `42.1648128` (26.2 miles) or `42.2`
- **THEN** it is treated as a custom distance, not as the Full Marathon preset

### Requirement: Preset Distances Display As Names
The system SHALL render the four preset distances as names rather than converted numbers,
in both units, because converting them produces labels no runner uses — a 10K is never a
"6.2mi race". Cards, badges, and other compact surfaces SHALL use the short forms `Full`,
`Half`, `10K`, and `5K`; the distance picker SHALL use the long forms `Full Marathon` and
`Half Marathon` alongside `10K` and `5K`. All preset names SHALL be sourced from the
String Catalog so they localize (`全馬` / `半馬` under `zh-TW`).

#### Scenario: Preset names are identical in both units
- **WHEN** a user views a medal card for a full marathon
- **THEN** the badge reads `Full` whether the unit preference resolves to kilometres or
  to miles

#### Scenario: Preset names localize
- **WHEN** the app language is 繁體中文 and a user views a full marathon medal card
- **THEN** the badge reads `全馬`

### Requirement: Measured Distance Display
The system SHALL display a distance measured in the active unit on exactly three
surfaces: the preset rows of the distance picker, the medal detail hero, and every custom
distance wherever it appears. For a **preset** distance the medal detail hero SHALL always
show both the name and the measurement, with no conditional suppression, so the rule holds
without exception even where the two restate each other (`10K · 10 km`). A **custom**
distance is already a measurement, so the hero SHALL show it once rather than repeating it.

Measured values SHALL be formatted to at most one fraction digit with a trailing zero
dropped, using the locale resolved from the app's language preference, and paired with a
String Catalog abbreviation (`km` / `mi`) rather than a Foundation-supplied unit name.

#### Scenario: Medal detail hero in miles
- **WHEN** the active unit is miles and a user opens a full marathon medal's detail screen
- **THEN** the hero reads `Full · 26.2 mi`

#### Scenario: Medal detail hero in kilometres
- **WHEN** the active unit is kilometres and a user opens a full marathon medal's detail
  screen
- **THEN** the hero reads `Full · 42.2 km`

#### Scenario: Redundant measurement is still shown
- **WHEN** the active unit is kilometres and a user opens a 10K medal's detail screen
- **THEN** the hero reads `10K · 10 km`

#### Scenario: A custom distance is not repeated on the hero
- **WHEN** the active unit is miles and a user opens the detail screen of a medal whose
  distance is a custom `16.09344` kilometres
- **THEN** the hero reads `10 mi`, not `10 mi · 10 mi`

#### Scenario: Trailing zero is dropped
- **WHEN** a distance of exactly 10 kilometres is displayed in kilometres
- **THEN** it reads `10 km`, not `10.0 km`

#### Scenario: Custom distance in the active unit
- **WHEN** a custom distance stored as `16.09344` kilometres is displayed
- **THEN** it reads `10 mi` in miles mode and `16.1 km` in kilometres mode

### Requirement: Pace Expressed In The Active Unit
The system SHALL express average pace per unit of the active distance unit — minutes per
kilometre or minutes per mile — converting from the kilometre-based pace held on the model.
Seconds are truncated rather than rounded, which is the app's existing behaviour and is
unchanged by this capability.

#### Scenario: Pace in miles
- **WHEN** the active unit is miles and a medal's pace is 5'41" per kilometre
- **THEN** the detail screen shows `9'08" /mi`

#### Scenario: Pace in kilometres
- **WHEN** the active unit is kilometres and a medal's pace is 5'41" per kilometre
- **THEN** the detail screen shows `5'41" /km`
