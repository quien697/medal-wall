## MODIFIED Requirements

### Requirement: Result Content
Each medal result SHALL show the medal's front, presented as the `medal-photos` capability's
medal image at 46 pt with no gold ring, then its date, its name, its displayed place, and its
distance on a line of its own. A medal result SHALL NOT show a finish time. Each race result
SHALL show the race's photo, its name, its displayed place and its edition count, the count
clamped to zero or more. Results SHALL NOT offer swipe actions.

#### Scenario: A medal found by its place
- **WHEN** the query "Taiwan" matches a medal run in Taipei City by its place alone
- **THEN** its row shows "Taipei City, Taiwan" beneath its name

#### Scenario: A long custom distance
- **WHEN** a matching medal's distance reads "Wheel Chair 9,999.9999 mi"
- **THEN** its row shows the whole distance on its own line, beneath the place

#### Scenario: A corrupt edition count
- **WHEN** a matching race's stored edition count is negative
- **THEN** its row shows "0 editions"

#### Scenario: A medal result shows its front
- **WHEN** a matching medal has a front photo
- **THEN** its row shows the front in a 46 pt square with no gold ring
