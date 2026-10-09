# profile Specification

## Purpose
Let a signed-in user view and edit their personal profile, and surface race statistics
computed on the fly from their medal list rather than stored on the `User` record. A profile
read from the device's local copy is shown but never written. Until the profile loads, the
You tab is blank.
## Requirements
### Requirement: Editable Profile
The system SHALL allow a signed-in user to view and edit their profile: first name,
last name, photo, bio, gender, and birthday. A removed photo SHALL be deleted from storage
only after the profile save succeeds. When two devices edit the profile, the last save wins.

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

#### Scenario: Profile save fails after removing the photo
- **WHEN** a user removes their photo and the profile save fails
- **THEN** the photo stays in storage and the profile still shows it

#### Scenario: Two devices edit the profile
- **WHEN** the same profile is saved from two devices
- **THEN** the save the server receives last replaces the profile

### Requirement: Computed Race Statistics
The system SHALL compute and display, from the user's medal list, the total number of
medals, the count of full and half marathon medals, and the best (lowest) finish time
recorded for full and half marathon distances. They SHALL be shown once the profile has
loaded (see Profile Not Yet Loaded).

#### Scenario: Stats update as medals change
- **WHEN** a user adds or deletes a medal with a full or half marathon distance
- **THEN** the displayed total medal count, distance counts, and best times reflect
  the change without being separately stored on the `User` record

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
Until the signed-in user's profile has loaded — while it loads, while offline with no copy on
the device, or after it fails — the system SHALL leave the You tab's content blank: no
header, no medal statistics, and no achievement progress. The title and toolbar SHALL stay, so
Settings remains reachable. Edit Profile SHALL be disabled. No error SHALL be shown.

#### Scenario: Profile has not loaded
- **WHEN** a signed-in user opens the You tab before their profile has loaded
- **THEN** the tab shows its title and toolbar over blank content, and Edit Profile is
  disabled

#### Scenario: Profile cannot load
- **WHEN** the profile cannot load for any reason
- **THEN** the You tab stays blank with no error, and Settings stays reachable
  so the user can sign out

#### Scenario: Profile loads later
- **WHEN** the profile loads after the You tab is showing
- **THEN** the tab shows the header, statistics and progress, and Edit Profile becomes
  available once the profile has come from the server

