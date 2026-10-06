## MODIFIED Requirements

### Requirement: Editable Profile
The system SHALL allow a signed-in user to view and edit their profile: first name,
last name, photo, bio, gender, and birthday. A removed photo SHALL be deleted from storage
only after the profile save succeeds. When two devices edit the profile, the last save wins.

#### Scenario: Edit profile fields
- **WHEN** a user updates their first name, last name, bio, gender, or birthday and
  saves
- **THEN** the system persists the updated `User` record

#### Scenario: Display name fallback
- **WHEN** a user has no first or last name set
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

## ADDED Requirements

### Requirement: Cached Profile Is Read-Only
A profile read from the device's local copy rather than the server can be older than the
server's copy. The system SHALL show it but SHALL NOT write it: Edit Profile SHALL be
disabled and milestone updates SHALL be skipped until the server's profile has loaded. The
system SHALL load the server's profile when the connection returns or the app comes back to
the foreground.

#### Scenario: App opened offline with a cached profile
- **WHEN** the app opens with the profile read from the device's local copy
- **THEN** the profile is shown and Edit Profile is disabled

#### Scenario: Medal saved against a cached profile
- **WHEN** a medal save would raise a milestone while the profile is the device's copy
- **THEN** no milestone is written, and the next medal saved after the server's profile has
  loaded catches it up

#### Scenario: Connection returns
- **WHEN** the connection returns, or the app comes back to the foreground, while the
  profile is the device's copy
- **THEN** the system loads the server's profile and Edit Profile becomes available
