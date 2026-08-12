## ADDED Requirements

### Requirement: String Catalog Infrastructure
The system SHALL source all app-authored UI strings from an Xcode String Catalog
(`Localizable.xcstrings`) rather than hardcoded literals, so new locales can be
added without changing call sites.

#### Scenario: Adding a new locale requires no code changes
- **WHEN** a new locale (e.g. Japanese) is added to the String Catalog with
  translated entries
- **THEN** the app can display that locale by adding one case to `AppLanguage`
  and populating the catalog — no call-site changes are needed

### Requirement: Supported Locales
The system SHALL support English (`en`, base) and Traditional Chinese (`zh-TW`)
at minimum. Untranslated keys in a supported locale SHALL fall back to English
rather than showing a missing-string placeholder.

#### Scenario: Partially translated catalog
- **WHEN** the user selects 繁體中文 and a string has no `zh-TW` translation yet
- **THEN** the app displays the English source string for that key rather than
  a blank or placeholder value

### Requirement: Consistent Locale Resolution Across SwiftUI and Model Code
The system SHALL resolve the active locale from a single stored preference and
apply it consistently to both SwiftUI-rendered text and display strings
constructed outside the view hierarchy (model and ViewModel computed
properties).

#### Scenario: Model-computed display string reflects the selected language
- **WHEN** the user selects 繁體中文 and a screen displays a `Division`'s
  `displayName` (e.g. "Male 30-34"), which is computed in a model type outside
  any SwiftUI view body
- **THEN** the displayed text is the 繁體中文 translation, not the English source

### Requirement: Localization Scope Excludes User-Entered Content
The system SHALL NOT translate user-entered free text persisted in Firestore
(race names, medal titles, notes, event photo captions). Such content SHALL
always display exactly as the user entered it, regardless of the active
language preference.

#### Scenario: User-entered race name under a non-English language
- **WHEN** the user selects 繁體中文 and views a race whose name was entered in
  English (or any other language) by a user
- **THEN** the race name displays unchanged, exactly as stored
