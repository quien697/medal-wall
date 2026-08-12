## ADDED Requirements

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
