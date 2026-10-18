## ADDED Requirements

### Requirement: Custom Distance Entry With Its Own Unit
The system SHALL accept a custom distance as a number together with a unit chosen by a
Kilometers / Miles switch beside the field. For a new custom distance the switch SHALL start
at the distance unit setting; for a stored custom distance it SHALL start at the stored
unit. The distance SHALL be stored with the number and unit as entered, with no conversion,
so opening and saving a distance without editing it never changes it.

A custom distance SHALL be greater than zero, a finite number, and have at most four
decimal places; any other value SHALL be refused with the invalid distance error. A number
and unit equal to a standard distance SHALL be saved as that standard distance.

#### Scenario: Entering a custom distance in miles
- **WHEN** a user sets the switch to Miles and enters a custom distance of `10`
- **THEN** the distance is stored as `10` miles and reads `10 mi`

#### Scenario: The switch starts at the distance unit setting
- **WHEN** the distance unit is Miles and a user chooses Custom for a new distance
- **THEN** the switch shows Miles

#### Scenario: A stored custom distance opens in its own unit
- **WHEN** the distance unit is Miles and a user opens a custom distance stored as `42.2`
  kilometres
- **THEN** the field shows `42.2` and the switch shows Kilometers, and saving without an
  edit leaves it stored as `42.2` kilometres

#### Scenario: More than four decimals is refused
- **WHEN** a user enters a custom distance of `10.12345`
- **THEN** it is refused with the invalid distance error and nothing is saved

#### Scenario: Zero is refused
- **WHEN** a user enters a custom distance of `0`
- **THEN** it is refused with the invalid distance error and nothing is saved

#### Scenario: A standard value saves the standard distance
- **WHEN** a user enters a custom distance of `42.195` with the switch at Kilometers
- **THEN** it is saved as the Full Marathon and reads `Full`

## MODIFIED Requirements

### Requirement: Preset And Custom Distances Coexist
The system SHALL NOT snap a custom distance to a nearby standard distance, and SHALL NOT
prompt the user to confirm whether a near-standard value was meant as a standard one. A
custom `42` km and a Full Marathon are therefore distinct distances that can both appear in
one edition. The edition's duplicate check SHALL compare the exact value, unit and race
type, so `10K` and a custom `10 mi` of the same type can both appear, while the same value
and unit twice cannot. The distance picker SHALL instead show each preset's stored
measurement, identical in both units, so a user looking for a known number finds it on the
preset row rather than typing it into the custom field.

#### Scenario: Preset rows show their measurement
- **WHEN** a user opens the distance picker, with the distance unit set to either
  Kilometers or Miles
- **THEN** the preset rows read `Full Marathon · 42.195 km`, `Half Marathon · 21.0975 km`,
  `10K · 10 km`, and `5K · 5 km`

#### Scenario: A near-preset custom distance is not snapped
- **WHEN** a user enters a custom distance of `26.2` miles rather than selecting the Full
  Marathon preset
- **THEN** the distance is stored as `26.2` miles and remains a custom distance, with no
  prompt and no conversion to the preset

#### Scenario: The same number in another unit is not a duplicate
- **WHEN** an edition already offers an in-person `10K` and a user adds an in-person custom
  `10 mi`
- **THEN** both distances are kept

#### Scenario: The same value and unit is a duplicate
- **WHEN** an edition already offers an in-person `10K` and a user adds an in-person custom
  `10` kilometres
- **THEN** it is refused as a duplicate distance

## REMOVED Requirements

### Requirement: Custom Distance Entry In The Active Unit
**Reason**: A custom distance is no longer entered in the active unit and converted to
kilometres; it is stored in the unit chosen on its own switch. Replaced by "Custom Distance
Entry With Its Own Unit".
**Migration**: None in code. Development documents are rewritten by hand to the `events`
shape.
