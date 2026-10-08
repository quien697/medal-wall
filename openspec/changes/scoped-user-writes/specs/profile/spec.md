## MODIFIED Requirements

### Requirement: Editable Profile
The system SHALL allow a signed-in user to view and edit their profile: first name,
last name, photo, bio, gender, and birthday. A removed photo SHALL be deleted from storage
only after the profile save succeeds. A profile save SHALL write only these fields and the
time of the edit; it MUST NOT write the milestone fields. When two devices edit the profile,
the last save wins for these fields.

#### Scenario: Edit profile fields
- **WHEN** a user updates their first name, last name, bio, gender, or birthday and
  saves
- **THEN** the system persists the updated profile fields on the `User` record

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
- **THEN** the save the server receives last replaces the profile fields

#### Scenario: Profile save from an older copy
- **WHEN** a device whose profile copy holds a lower milestone than the server stores saves
  a profile edit
- **THEN** the stored milestones are unchanged
