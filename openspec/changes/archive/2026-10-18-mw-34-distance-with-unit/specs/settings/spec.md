## MODIFIED Requirements

### Requirement: Distance Unit Preference
The system SHALL allow a user to choose a distance unit — Kilometers or Miles — and SHALL
apply it immediately to every displayed pace and to the starting unit of a new custom
distance. It SHALL NOT change how any distance is displayed. The preference is stored
locally on-device and is not synced across devices. Unlike Appearance and Language, this
picker has no System option: the device only seeds the initial value, and what gets stored
is always a concrete unit. How that seeding works, and how pace is expressed, are owned by
the `distance-units` capability.

Settings SHALL describe, beneath the Preferences section, what the distance unit affects:
the pace unit and the starting unit of a custom distance, while distances always show as
they were entered.

#### Scenario: User switches distance unit
- **WHEN** a user selects Kilometers or Miles in the distance picker
- **THEN** every displayed pace updates immediately, without an app restart, every displayed
  distance reads as before, and the choice persists across app restarts on that device

#### Scenario: Picker opens on the device-derived unit
- **WHEN** a user who has never chosen a unit opens the distance picker on a US-region
  device
- **THEN** Miles is shown as the current selection

#### Scenario: Switching the unit dismisses Settings
- **WHEN** a user changes the distance unit while the Settings screen is open
- **THEN** the app re-renders and Settings is closed, matching the existing behaviour
  of changing the app language

#### Scenario: Settings describes what the unit affects
- **WHEN** a user opens Settings
- **THEN** beneath the Preferences section a description states that the distance unit sets
  the pace unit and the starting unit for a custom distance, and that distances always show
  as they were entered
