## Why

The app currently ships with every string hardcoded in English and no localization
infrastructure at all. The user wants to add 繁體中文 (Traditional Chinese, `zh-TW`)
as a first additional language, with the architecture set up so further languages
can be added later without rework. Tracked in Jira [MW-26](https://quien.atlassian.net/browse/MW-26).

## What Changes

- Introduce an Xcode String Catalog (`Localizable.xcstrings`) as the app's
  localization infrastructure — none exists today.
- Extract all app-authored UI strings (labels, buttons, section headers, error
  messages, empty states) across the app into the catalog, including display
  strings for app-defined enums that render as UI text (`RaceDistanceCategory`,
  `RaceDistanceType`, `Division`).
- Add `zh-TW` (Traditional Chinese) as a second supported locale with translated
  strings, reviewed by the user before merge (not shipped as machine-translation
  final copy).
- Add a "Language" row to `SettingsView`'s Preferences section, next to
  `AppearancePicker`: System / English / 繁體中文. Selecting a language applies
  it immediately without an app restart.
- User-entered free text stored in Firestore (race names, medal titles, notes,
  event photo captions) is explicitly **not** translated — it stays as entered.

## Capabilities

### New Capabilities
- `localization`: App-wide string catalog infrastructure, supported locales, and
  the rule for what content is (UI chrome, app-defined enum labels) vs. isn't
  (user-entered Firestore free text) translated.

### Modified Capabilities
- `settings`: Adds a Language preference (System / English / 繁體中文) alongside
  the existing Appearance preference — same storage/apply/sync-scope pattern:
  stored locally via `@AppStorage`, applied immediately, not synced across devices.

## Impact

- `SettingsView.swift` — new "Language" row alongside `AppearancePicker`.
- New `LanguagePicker` component (mirrors `AppearancePicker`).
- New `Localizable.xcstrings` String Catalog; Xcode project settings gain a
  `zh-TW` localization.
- Every view/viewmodel with a hardcoded English string — string literals become
  catalog-backed (`String(localized:)` / `LocalizedStringKey` / `Text("key")`).
- `RaceDistanceCategory`, `RaceDistanceType`, `Division` — their display-string
  computed properties route through the catalog instead of returning raw English.
- No changes to Firestore schema or data model — this is presentation-layer only.
