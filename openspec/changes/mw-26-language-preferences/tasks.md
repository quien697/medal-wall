## 1. String Catalog & Project Setup

- [x] 1.1 Add `Localizable.xcstrings` to the Xcode project (base language `en`)
- [x] 1.2 Add `zh-TW` as a project localization in build settings
- [x] 1.3 Verify a build with `zh-TW` selected as the simulator language falls
      back to English for all (still-untranslated) strings

## 2. Locale Model & Resolution

- [x] 2.1 Write failing tests for `AppLanguage`: `label`, `locale` per case
      (`.system` → `nil`, `.english` → `Locale(identifier: "en")`, `.zhTW` →
      `Locale(identifier: "zh-TW")`)
- [x] 2.2 Implement `AppLanguage` enum (`Shared/UIModels/AppLanguage.swift`),
      mirroring `AppTheme.swift`'s structure
- [x] 2.3 Implement `AppLanguage.resolvedLocale` static helper that reads the
      `appLanguage` `@AppStorage`/`UserDefaults` key directly, for use by
      non-SwiftUI model/ViewModel code (per design.md Decision 3)
- [x] 2.4 Write failing tests for `resolvedLocale` covering all three stored
      values plus the unset/default case

## 3. Root Wiring

- [x] 3.1 Add `@AppStorage("appLanguage") private var appLanguage: AppLanguage = .system`
      to `MedalWallApp`
- [x] 3.2 Inject `.environment(\.locale, ...)` on the root `Group`, alongside
      the existing `.preferredColorScheme(appTheme.colorScheme)`
- [ ] 3.3 Manually verify: switching the picker updates SwiftUI `Text` content
      immediately without relaunch — **partially done:** launch-time resolution
      verified in the simulator (app renders 繁體中文 end to end); the live
      in-app picker switch is behind Firebase auth and needs the user's
      walkthrough

## 4. Settings UI

- [x] 4.1 Build `LanguagePicker` component mirroring `AppearancePicker`
      (`Features/Setting/`)
- [x] 4.2 Add "Language" row to `SettingsView`'s Preferences section, next to
      `AppearancePicker`
- [x] 4.3 Add/update `#Preview` for `SettingsView` and `LanguagePicker`
      (named previews per project convention)

## 5. Non-SwiftUI Display Strings

- [x] 5.1 Write failing tests asserting `Division.displayName`,
      `AgeGroup.displayName`, and `Gender.shortName` (or equivalent) return
      the `zh-TW` translation when resolved locale is `zh-TW`, and English
      otherwise
- [x] 5.2 Convert those computed properties to route through
      `String.appLocalized(_:)` — `String(localized:locale:)` does not select a
      localization table, so the helper resolves the matching `.lproj` bundle
      instead (see design.md Decision 3, "Corrected during implementation")
- [x] 5.3 Audit `RaceDistanceType`, `AppError` messages, and any other
      `Codable`/model computed `String` properties for English literals;
      convert the same way
- [x] 5.4 Re-run the full model test suite to confirm no regressions

## 6. UI String Extraction (English source strings)

- [x] 6.1 Extract strings in `Features/Login/`
- [x] 6.2 Extract strings in `Features/Main/`
- [x] 6.3 Extract strings in `Features/Medal/`
- [x] 6.4 Extract strings in `Features/Profile/`
- [x] 6.5 Extract strings in `Features/Race/`
- [x] 6.6 Extract strings in `Features/Setting/` (excluding the new
      `LanguagePicker`, already catalog-backed from Task 4)
- [x] 6.7 Extract strings in shared/reusable components (`Shared/` views,
      `ErrorView`, empty states, alerts)
- [x] 6.8 Build the app and confirm no leftover hardcoded literals remain via
      an Xcode "Find in Project" sweep for quoted strings in `Text(...)`

## 7. 繁體中文 Translations

- [x] 7.1 Fill in `zh-TW` entries in `Localizable.xcstrings` for all extracted
      keys
- [x] 7.2 Fill in `zh-TW` entries for the `Division`/`AgeGroup`/etc. keys from
      Task 5
- [ ] 7.3 User (Quien) reviews all `zh-TW` copy before merge — **awaiting review**

## 8. Verification

- [x] 8.1 Run full test suite (`xcodebuild test`)
- [ ] 8.2 Manual pass: switch language via Settings, walk through each screen
      in both English and 繁體中文, confirm immediate application and no
      truncation/layout breakage from longer/shorter translated strings —
      **partially done:** the login screen was verified in both languages via the
      simulator; the signed-in screens need a device/account walkthrough by the user
- [x] 8.3 Confirm Firestore-sourced free text (race names, medal titles,
      notes, photo captions) is unaffected by the language switch
- [x] 8.4 Update `openspec/specs/settings/spec.md` will happen automatically
      at archive time — no manual edit needed now
