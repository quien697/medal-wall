## ADDED Requirements

### Requirement: Canonical Location Representation
The system SHALL represent a location as an ISO 3166-1 alpha-2 country code, a city name, an
optional region, and optional coordinates. The country code and the coordinates SHALL be the
canonical values, and SHALL be the only ones used to group, filter, or compare locations,
because they are defined independently of any map or geocoding provider. The city and region
SHALL be treated as display values only, since providers divide administrative levels
differently for the same place and therefore disagree on which value is the city.

#### Scenario: Country stored as a code rather than a name
- **WHEN** a location is recorded from any place-search provider
- **THEN** the system stores an ISO 3166-1 alpha-2 country code rather than a country name,
  so records created by different clients for the same country share one value

#### Scenario: Locations are compared only by provider-independent values
- **WHEN** locations recorded by different client platforms for the same place are grouped or
  compared
- **THEN** the system uses only the country code and the coordinates, and never the city or
  region values, which may legitimately differ between providers for that same place

### Requirement: Place Search and Selection
The system SHALL allow a user to record a location by searching for a place by name and
selecting from the results, rather than typing each location field separately.

#### Scenario: Results appear as the user types
- **WHEN** a user types a query into the location search field
- **THEN** the system displays a list of matching place suggestions and updates them as the
  query changes

#### Scenario: Selecting a result fills the location
- **WHEN** a user selects a place suggestion
- **THEN** the system resolves it into a complete location — country code, city, optional
  region, and coordinates — applies it, and dismisses the search

#### Scenario: Search returns no matches
- **WHEN** a query matches no places
- **THEN** the system shows an empty-results state and leaves the current location unchanged

#### Scenario: Search or resolution fails
- **WHEN** a place search or the resolution of a selected suggestion fails, such as when the
  device is offline
- **THEN** the system surfaces the failure as an application error and leaves the current
  location unchanged

### Requirement: Manual Location Fallback
The system SHALL allow a user to enter or amend a location without using place search, so
that a location can still be recorded when the device is offline or when the provider does
not know the place.

#### Scenario: Recording a location without search
- **WHEN** place search is unavailable or returns no match for a place
- **THEN** the user can still record a location by entering it directly

#### Scenario: Amending a location returned by search
- **WHEN** a user has applied a location by selecting a search result
- **THEN** the user can still amend that location before saving

### Requirement: Locale-Aware Location Display
The system SHALL derive a location's display text from its stored fields at read time rather
than storing a formatted string, and SHALL render the country from its stored country code
in the viewer's own language.

#### Scenario: Country rendered in the viewer's language
- **WHEN** a location whose stored country code is `TW` is displayed
- **THEN** the system shows the country name localized for the viewer, so one stored record
  reads correctly in any language

#### Scenario: Absent components are omitted from the display
- **WHEN** a location missing a region is displayed, and separately one missing a city
- **THEN** the display omits each absent component entirely, leaving no empty separators and
  no placeholder text

### Requirement: Reading Previously Stored Locations
The system SHALL read locations written in the previous four-field shape — country name,
province, city, district — without requiring a data migration, and SHALL write the current
shape the next time such a record is saved.

#### Scenario: Reading a location stored in the previous shape
- **WHEN** a location stored as country name, province, city, and district is read
- **THEN** the system maps city to city and province to region, resolves the country name to
  its ISO 3166-1 alpha-2 code, and leaves coordinates absent

#### Scenario: A stored country name cannot be resolved to a code
- **WHEN** a country name in a previously stored location does not resolve to a country code
- **THEN** the system reads the record without failing and the remaining location fields stay
  intact

### Requirement: Coordinate Validation
The system SHALL validate stored coordinates when reading a location. A latitude outside
−90 through 90, or a longitude outside −180 through 180, SHALL be treated as absent rather
than used.

#### Scenario: Out-of-range coordinate is discarded
- **WHEN** a location is read whose stored latitude or longitude falls outside its valid range
- **THEN** the system treats that coordinate as absent and the location remains usable
