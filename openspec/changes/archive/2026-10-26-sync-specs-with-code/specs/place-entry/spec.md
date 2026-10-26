## MODIFIED Requirements

### Requirement: Canonical Place Representation
The system SHALL represent a place as an ISO 3166-1 alpha-2 country code, a city name, and an
optional region. Places SHALL be recorded at area level; the system SHALL NOT store a
coordinate or any street-level position. The country code SHALL be the canonical value, and
SHALL be the only one used to group places or to decide whether two places are the same,
because it is the only field defined independently of any map or geocoding provider. The city
and region SHALL be treated as display values only, since providers divide administrative
levels differently for the same place and therefore disagree on which value is the city. Text
search SHALL match a place as the app displays it, city and region included, because it finds
what the user reads on screen rather than deciding that two places are the same.

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

#### Scenario: Text search matches the displayed place
- **WHEN** a user searches for "Taipei" and a race's place displays as "New Taipei City, Taiwan"
- **THEN** the race is found, and no two places are treated as the same because of it
