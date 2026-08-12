# settings Specification

## Purpose
Hold the user's app-level preferences — the appearance mode (system/light/dark) and the
app language (system/English/繁體中文) — each applied immediately and stored locally
on-device rather than synced.
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

