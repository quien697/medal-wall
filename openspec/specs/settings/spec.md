# settings Specification

## Purpose
TBD - created by archiving change baseline-current-capabilities. Update Purpose after archive.
## Requirements
### Requirement: Appearance Preference
The system SHALL allow a user to choose an appearance mode — system, light, or dark —
and SHALL apply it immediately. The preference is stored locally on-device and is not
synced across devices.

#### Scenario: User switches appearance mode
- **WHEN** a user selects light, dark, or system in the appearance picker
- **THEN** the app's color scheme updates immediately and persists across app
  restarts on that device

