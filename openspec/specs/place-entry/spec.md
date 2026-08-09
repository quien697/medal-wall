# place-entry Specification

## Purpose
Own how a place is represented, chosen, and displayed wherever a race or medal records one.
A place is an ISO 3166-1 alpha-2 country code plus a display-only city and optional region,
recorded at area level and set only by searching and selecting — never by typing — so that one
place yields one value across every client platform that reads the same records.
## Requirements
### Requirement: Canonical Place Representation
The system SHALL represent a place as an ISO 3166-1 alpha-2 country code, a city name, and an
optional region. Places SHALL be recorded at area level; the system SHALL NOT store a
coordinate or any street-level position. The country code SHALL be the canonical value, and
SHALL be the only one used to group, filter, or compare places, because it is the only field
defined independently of any map or geocoding provider. The city and region SHALL be treated
as display values only, since providers divide administrative levels differently for the same
place and therefore disagree on which value is the city.

#### Scenario: Country stored as a code rather than a name
- **WHEN** a place is recorded from any search provider
- **THEN** the system stores an ISO 3166-1 alpha-2 country code rather than a country name,
  so records created by different clients for the same country share one value

#### Scenario: Places are compared only by provider-independent values
- **WHEN** records created by different client platforms for the same place are grouped or
  compared
- **THEN** the system uses only the country code, and never the city or region values, which
  may legitimately differ between providers for that same place

#### Scenario: Area-level detail is enough to identify a race
- **WHEN** a race is known colloquially by a township that differs from its administrative
  city, such as 田中馬拉松 held in 田中鎮 of 彰化縣
- **THEN** the system records 彰化縣 and stores no finer detail; the familiar 田中 name is
  carried by the race's own name, not by its place

### Requirement: Place Search and Selection
The system SHALL require a place to be recorded by searching and selecting from the results.
The system SHALL NOT accept a hand-typed place, because free text reintroduces the spelling
variance this capability exists to eliminate and any value it wrote would persist.

#### Scenario: Results appear as the user types
- **WHEN** a user types a query into the place search field
- **THEN** the system displays a list of matching suggestions and updates them as the query
  changes

#### Scenario: Selecting a result fills the place
- **WHEN** a user selects a suggestion
- **THEN** the system resolves it into a complete place — country code, city, and optional
  region — applies it, and dismisses the search

#### Scenario: Search returns no matches
- **WHEN** a query matches nothing
- **THEN** the system shows an empty-results state and leaves the current place unchanged

#### Scenario: Search or resolution fails
- **WHEN** a search, or the resolution of a selected suggestion, fails — such as when the
  device is offline
- **THEN** the system surfaces the failure as an application error and leaves the current
  place unchanged

#### Scenario: A place cannot be typed by hand
- **WHEN** a user opens the place section of a race or medal form
- **THEN** the only way to set a place is to search and select one; no field accepts a typed
  city, region, or country

### Requirement: City-Level Normalization
A selected place SHALL be recorded at city level. Where a provider returns an administrative
unit below the city — a district, township, or ward — and that unit's parent is itself the
city, the system SHALL record the parent and discard the sub-unit, so that one place yields
one value regardless of how precisely it was searched for.

#### Scenario: A district resolves to its city
- **WHEN** a user selects a district whose containing administrative area is the city, such
  as 復興區 within 桃園市
- **THEN** the system records 桃園市 as the city and records no region, rather than storing
  the district

#### Scenario: A city-level result is recorded directly
- **WHEN** a user selects a place that is already a city and the provider returns no sub-unit
  for it
- **THEN** the system records that city rather than leaving the city empty

#### Scenario: A region is kept where it distinguishes the city
- **WHEN** a user selects a city in a country whose administrative area is a state or
  province, such as Portland in Oregon
- **THEN** the system records the city and keeps the state as the region, so cities sharing a
  name in different states remain distinguishable

### Requirement: Locale-Aware Place Display
The system SHALL derive a place's display text from its stored fields at read time rather
than storing a formatted string, and SHALL render the country from its stored country code in
the viewer's own language.

#### Scenario: Country rendered in the viewer's language
- **WHEN** a place whose stored country code is `TW` is displayed
- **THEN** the system shows the country name localized for the viewer, so one stored record
  reads correctly in any language

#### Scenario: Absent components are omitted from the display
- **WHEN** a place missing a region is displayed, and separately one missing a city
- **THEN** the display omits each absent component entirely, leaving no empty separators and
  no placeholder text
