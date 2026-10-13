## MODIFIED Requirements

### Requirement: Year Grouping
The system SHALL group the presented medals by the Gregorian year of each medal's date,
with the most recent year first. Each group SHALL carry a header showing the year and the
number of medals in that group. A year with no medals in the presented set SHALL NOT
produce a group, so the list never shows an empty year. Years are Gregorian whatever calendar
the device uses, so they match the years editions are stored with.

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
