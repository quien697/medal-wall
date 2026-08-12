## ADDED Requirements

### Requirement: Distance Unit Preference
The system SHALL allow a user to choose a distance unit — System, Kilometers, or Miles —
and SHALL apply it immediately to every displayed distance and pace. The preference is
stored locally on-device and is not synced across devices. How System resolves, and how
values are converted and formatted, are owned by the `distance-units` capability.

#### Scenario: User switches distance unit
- **WHEN** a user selects System, Kilometers, or Miles in the distance picker
- **THEN** every displayed distance and pace updates immediately, without an app restart,
  and the choice persists across app restarts on that device

#### Scenario: Switching the unit dismisses Settings
- **WHEN** a user changes the distance unit while the Settings sheet is open
- **THEN** the app re-renders and the sheet is dismissed, matching the existing behaviour
  of changing the app language
