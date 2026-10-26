## MODIFIED Requirements

### Requirement: Pace Expressed In The Active Unit
The system SHALL calculate average pace from the recorded finish time and the real length of
the distance, whichever unit the distance is stored in, and SHALL express it per unit of the
active distance unit — minutes per kilometre or minutes per mile. Converting a distance to
its real length is done in memory only and is never shown or stored. Seconds are truncated
rather than rounded, which is the app's existing behaviour.

There SHALL be no pace when the medal has no recorded finish time, as the `medals` capability
defines one, when its distance is not a positive, finite number, or when the pace works out at
1,000 minutes per unit or slower, which no one ran and only a distance stored near zero gives.

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

#### Scenario: A distance stored near zero has no pace
- **WHEN** a medal with a finish time of 3:00:00 has a distance stored as `0.0001` kilometres
- **THEN** no pace is shown
