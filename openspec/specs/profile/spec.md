# profile Specification

## Purpose
Let a signed-in user view and edit their personal profile, and surface race statistics
computed on the fly from their medal list rather than stored on the `User` record. A profile
read from the device's local copy is shown but never written. While the profile loads, the
You tab's header shows as bones; a profile that cannot load shows an empty state.
## Requirements
### Requirement: Editable Profile
The system SHALL allow a signed-in user to view and edit their profile: first name,
last name, photo, bio, gender, and birthday. A new photo SHALL be uploaded to a new storage
location, never over the one the profile points at. A removed or replaced photo SHALL be
deleted from storage only after the profile save succeeds, and a photo uploaded for a save
that fails SHALL be deleted. When two devices edit the profile, the last save wins.

#### Scenario: Edit profile fields
- **WHEN** a user updates their first name, last name, bio, gender, or birthday and
  saves
- **THEN** the system persists the updated `User` record

#### Scenario: Display name fallback
- **WHEN** a user's loaded profile has no first or last name set
- **THEN** the system displays "Runner" as their name

#### Scenario: Remove the profile photo
- **WHEN** a user removes their photo and the profile save succeeds
- **THEN** the system deletes the photo from storage

#### Scenario: Replace the profile photo
- **WHEN** a user picks a new photo and the profile save succeeds
- **THEN** the profile shows the new photo and the old one is deleted from storage

#### Scenario: Profile save fails after changing the photo
- **WHEN** a user removes or replaces their photo and the profile save fails
- **THEN** the old photo stays in storage, the profile still shows it, and any photo uploaded
  for the save is deleted

#### Scenario: Two devices edit the profile
- **WHEN** the same profile is saved from two devices
- **THEN** the save the server receives last replaces the profile

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

### Requirement: Cached Profile Is Read-Only
A profile read from the device's local copy rather than the server can be older than the
server's copy. The system SHALL show it but SHALL NOT write it: Edit Profile SHALL be
disabled until the server's profile has loaded. The system SHALL load the server's profile
when the connection returns or the app comes back to the foreground.

#### Scenario: App opened offline with a cached profile
- **WHEN** the app opens with the profile read from the device's local copy
- **THEN** the profile is shown and Edit Profile is disabled

#### Scenario: Connection returns
- **WHEN** the connection returns, or the app comes back to the foreground, while the
  profile is the device's copy
- **THEN** the system loads the server's profile and Edit Profile becomes available

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

### Requirement: You Tab Loading
The You tab's statistics and achievements SHALL never come from an older load than the one
they already show: a load's medals SHALL be used unless a newer load's medals already are, and
only the newest load SHALL present an error or end the loading state.

#### Scenario: An older load finishes last
- **WHEN** a load that started before a medal was deleted finishes after the load that started
  on returning to the You tab
- **THEN** the statistics leave the deleted medal out

#### Scenario: An older load fails last
- **WHEN** an older load fails after a newer load has loaded the medals
- **THEN** no error is shown and the statistics from the newer medals stay

#### Scenario: An older load finishes first
- **WHEN** an older load finishes while a newer load is still running
- **THEN** its statistics show, and the tab stays loading until the newer load finishes

#### Scenario: A newer load fails after an older one loaded
- **WHEN** an older load succeeds while a newer load runs, and the newer load then fails
- **THEN** the statistics from the older load stay, and the error shows

