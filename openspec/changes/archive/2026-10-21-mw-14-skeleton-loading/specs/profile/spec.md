## MODIFIED Requirements

### Requirement: Computed Race Statistics
The system SHALL compute and display, from the user's medal list, the total number of
medals, the count of full and half marathon medals, and the best (lowest) finish time
recorded for full and half marathon distances. The statistics and achievement progress SHALL
show as bones until the medals load, then as values, whether or not the profile has loaded
yet. A profile that cannot load replaces them with the You tab's empty state (see Profile Not
Yet Loaded).

#### Scenario: Stats update as medals change
- **WHEN** a user adds or deletes a medal with a full or half marathon distance
- **THEN** the displayed total medal count, distance counts, and best times reflect
  the change without being separately stored on the `User` record

#### Scenario: Medals load before the profile
- **WHEN** the user's medals load while the profile is still loading
- **THEN** the statistics and achievement progress show their values while the header still
  shows bones

#### Scenario: Medals cannot load
- **WHEN** the user's medals cannot load and the profile has loaded
- **THEN** the statistics show zero counts and no best times, the achievements show no
  progress, and the error sheet is presented

### Requirement: Profile Not Yet Loaded
While the signed-in user's profile loads, the You tab's header SHALL show as bones. When the
profile cannot load — while offline with no copy on the device, or after it fails — the
system SHALL show the You tab's empty state in place of all its content, with no header,
statistics or achievement progress even if the medals have loaded, and SHALL present the
error sheet for each failed load. The title and toolbar SHALL stay, so Settings remains
reachable. Edit Profile SHALL be disabled until the profile has loaded.

#### Scenario: Profile has not loaded
- **WHEN** a signed-in user opens the You tab before their profile has loaded
- **THEN** the tab shows its title and toolbar over bones for the header, and Edit Profile is
  disabled

#### Scenario: Profile cannot load
- **WHEN** the profile cannot load for any reason
- **THEN** the You tab shows its empty state in place of the header, statistics and
  achievements, the error sheet is presented, and Settings stays reachable so the user can
  sign out

#### Scenario: Profile loads after failing
- **WHEN** the profile is loaded again after failing, because the connection returned or the
  app came back to the foreground
- **THEN** the header shows bones while it loads, then the header, statistics and progress
  replace the empty state

#### Scenario: Profile loads later
- **WHEN** the profile loads after the You tab is showing
- **THEN** the header replaces its bones, and Edit Profile becomes available once the profile
  has come from the server
