# settings Specification

## Purpose
Hold the user's app-level preferences — the appearance mode (system/light/dark), the app
language (system/English/繁體中文), and the distance unit (kilometers/miles) — each applied
immediately and stored locally on-device rather than synced.
## Requirements
### Requirement: Appearance Preference
The system SHALL allow a user to choose an appearance mode — system, light, or dark —
and SHALL apply it immediately. The preference is stored locally on-device and is not
synced across devices.

#### Scenario: User switches appearance mode
- **WHEN** a user selects light, dark, or system in the appearance picker
- **THEN** the app's color scheme updates immediately and persists across app
  restarts on that device

### Requirement: Language Preference
The system SHALL allow a user to choose an app language — System, English, or
繁體中文 (`zh-TW`) — and SHALL apply it immediately. The preference is stored
locally on-device and is not synced across devices.

#### Scenario: User switches language
- **WHEN** a user selects System, English, or 繁體中文 in the language picker
- **THEN** the app's displayed language updates immediately, without an app
  restart, and persists across app restarts on that device

#### Scenario: System option follows device locale
- **WHEN** a user selects System
- **THEN** the app displays in the device's current language if a translation
  exists in the String Catalog, otherwise falls back to English

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
