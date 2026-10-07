## ADDED Requirements

### Requirement: Profile Not Yet Loaded
Until the signed-in user's profile has loaded — while it loads, while offline with no copy on
the device, or after it fails — the system SHALL leave the You tab's content blank: no
header, no medal statistics, and no achievement progress. The title and toolbar SHALL stay, so
Settings remains reachable. Edit Profile SHALL be disabled and milestone updates SHALL be
skipped. No error SHALL be shown.

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
- **THEN** the tab shows the header, statistics and progress, and Edit Profile becomes available once the profile has
  come from the server
