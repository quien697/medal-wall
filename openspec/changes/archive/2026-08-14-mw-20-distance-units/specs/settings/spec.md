## ADDED Requirements

### Requirement: Distance Unit Preference
The system SHALL allow a user to choose a distance unit — Kilometers or Miles — and SHALL
apply it immediately to every displayed distance and pace. The preference is stored locally
on-device and is not synced across devices. Unlike Appearance and Language, this picker has
no System option: the device only seeds the initial value, and what gets stored is always a
concrete unit. How that seeding works, and how values are converted and formatted, are
owned by the `distance-units` capability.

#### Scenario: User switches distance unit
- **WHEN** a user selects Kilometers or Miles in the distance picker
- **THEN** every displayed distance and pace updates immediately, without an app restart,
  and the choice persists across app restarts on that device

#### Scenario: Picker opens on the device-derived unit
- **WHEN** a user who has never chosen a unit opens the distance picker on a US-region
  device
- **THEN** Miles is shown as the current selection

#### Scenario: Switching the unit dismisses Settings
- **WHEN** a user changes the distance unit while the Settings sheet is open
- **THEN** the app re-renders and the sheet is dismissed, matching the existing behaviour
  of changing the app language
