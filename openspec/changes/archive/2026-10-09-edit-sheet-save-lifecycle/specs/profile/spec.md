## MODIFIED Requirements

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
