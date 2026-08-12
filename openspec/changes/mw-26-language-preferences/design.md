## Context

The app has zero localization infrastructure today — every string is a hardcoded
English literal, and `Text` calls scattered through views are not pulling from any
catalog. Two other properties already follow the pattern this change extends:
`appTheme` (`AppTheme` enum + `@AppStorage`, applied via `.preferredColorScheme` at
the root `Group` in `MedalWallApp.swift`) shows how a device-local, immediately-applied
preference is wired end to end.

Critically, not all display text lives in SwiftUI `body`. Per project convention
("No logic or computed properties in views — all derived values belong in the
ViewModel"), several user-facing strings are built in plain Swift model code, e.g.
`Division.displayName` (`"\(gender.shortName) \(ageGroup.displayName)"`, e.g. "Male
30-34") and `AgeGroup.displayName`. These return plain `String`, not
`LocalizedStringKey`, and run outside the SwiftUI view hierarchy — so they cannot
pick up a locale from `.environment(\.locale)`. (`RaceDistanceCategory.description`
turns out to be purely numeric, e.g. "42km" — not a translation target.)

## Goals / Non-Goals

**Goals:**
- Single source of truth for "what language is active" that works for both
  SwiftUI `Text` and plain-Swift string construction in models/ViewModels.
- Applied immediately, no app restart — matches the `appTheme` UX.
- Adding a third language later means: add a locale to the String Catalog, add
  translated entries, add one enum case. No structural rework.

**Non-Goals:**
- Translating Firestore free text (race names, medal titles, notes, captions).
- Per-field mixed-language content (a medal's title in Chinese and English) —
  content stays in whatever language the user entered it.
- Full RTL layout support (not needed for English/zh-TW).

## Decisions

**1. `zh-TW` over `zh-Hant` as the locale identifier.**
Apple's current guidance favors the script-based `zh-Hant` (region-independent)
over the region-based `zh-TW` for new apps. The user explicitly chose `zh-TW`
(matches the target audience — Taiwan — and is still fully supported by Xcode's
String Catalog and `Locale`/`Bundle` resolution). Going with `zh-TW` per that
decision; noting the trade-off here rather than silently overriding it.

**2. `AppLanguage` enum mirrors `AppTheme` exactly.**
```swift
enum AppLanguage: String, CaseIterable {
  case system, english, zhTW
  var label: String { ... }        // "System" / "English" / "繁體中文"
  var locale: Locale? { ... }      // nil / Locale(identifier: "en") / Locale(identifier: "zh-TW")
}
```
`nil` means "follow device locale" — same convention as `AppTheme.colorScheme`
returning `nil` for `.system`.

**3. Two propagation paths from one `@AppStorage` value — both required.**
- **SwiftUI layer:** `MedalWallApp` resolves the effective `Locale` (device locale
  when `.system`, otherwise the enum's fixed locale) and injects it once via
  `.environment(\.locale, resolvedLocale)` on the root `Group`, alongside the
  existing `.preferredColorScheme(appTheme.colorScheme)`. This covers all
  `Text(LocalizedStringKey)` usage and locale-sensitive formatters (dates, numbers)
  automatically.
- **Non-SwiftUI layer:** model/ViewModel code that builds display strings outside
  `body` (e.g. `Division.displayName`, `AgeGroup.displayName`) cannot see the
  SwiftUI environment. These call `String.appLocalized(_:)`, a helper that reads
  the same `@AppStorage` key directly (`AppLanguage.stored`) — one `@AppStorage`
  key, two consumers, not two sources of truth.

  **Corrected during implementation:** the original plan was
  `String(localized:locale:)`. That does *not* work — verified empirically
  (`LocalizationTests`): the `locale:` parameter only formats interpolated values,
  it does **not** select a localization table, so the call returned the English
  source string under `zh-TW`. The working mechanism is to resolve the matching
  `.lproj` bundle explicitly (`AppLanguage.resolvedBundle`, via
  `Bundle.preferredLocalizations` → `Bundle(path:)`) and pass it as
  `String(localized:bundle:locale:)`. `Bundle.main` is the fallback and yields the
  English source string, which is also what gives untranslated keys their
  English fallback.

- **View parameters typed `String` are a third, silent path.** A shared component
  taking `title: String` and rendering `Text(title)` does not localize at all —
  `Text(String)` skips catalog lookup. These parameters are retyped to
  `LocalizedStringKey`, which leaves the call sites unchanged (string literals
  convert implicitly).

- **Immediate application requires `.id(appLanguage)` on the root `Group`.**
  Environment-locale changes only invalidate views that read `\.locale`; strings
  built through `String.appLocalized` read `UserDefaults` non-reactively and would
  otherwise stay stale until the next natural redraw. Keying the root on the
  preference rebuilds the tree on change. Trade-off: switching language resets
  navigation state to the root, which is acceptable for a rare, deliberate action.

**4. String Catalog (`Localizable.xcstrings`), not legacy `.strings` files.**
Standard for iOS 26 projects — Xcode extracts `Text("...")`/`String(localized:)`
call sites automatically and provides a translation UI. No `NSLocalizedString`
manual key management.

**5. `LanguagePicker` component mirrors `AppearancePicker`.**
Same list-row picker UI pattern already established for `appTheme`, in the same
Preferences section of `SettingsView`.

## Risks / Trade-offs

- **[Risk]** Missing a non-SwiftUI string-construction call site (leaving it on
  the environment-only path) means it silently stays English when the user
  switches to 繁體中文, with no compiler error. → **Mitigation:** grep for every
  `String` return in `Models/`, `Shared/`, and ViewModel computed properties during
  extraction (tasks.md item); add one test per translated model computed property
  asserting the string changes across the two locales.
- **[Risk]** `zh-TW` chosen over `zh-Hant` diverges from Apple's current
  recommendation; if Hong Kong/Macau users are ever targeted, `zh-TW` reads as
  Taiwan-specific. → **Mitigation:** accepted per explicit user decision; low cost
  to add `zh-Hant` as an additional catalog locale later if needed — the enum/
  picker structure already supports adding cases.
- **[Risk]** Large diff — touching most view files to replace English literals
  with catalog keys — increases review surface and merge-conflict risk with any
  parallel feature branch. → **Mitigation:** mechanical, low-risk changes (string
  literal → catalog key); land as its own branch/PR ahead of/independent from
  other in-flight feature work.

## Migration Plan

1. Add `Localizable.xcstrings` to the Xcode project; add `zh-TW` as a project
   localization.
2. Add `AppLanguage` enum + `LanguagePicker` + `@AppStorage("appLanguage")` wiring
   in `MedalWallApp` (environment) — ships with only `en` populated, `zh-TW` falls
   back to English (Xcode's default catalog behavior for untranslated keys).
3. Extract UI strings screen by screen into the catalog (English source strings).
4. Fix non-SwiftUI string construction to use `String(localized:locale:)` with the
   resolved locale (per Decision 3).
5. Add `zh-TW` translations to the catalog; user reviews before merge.
6. No rollback complexity — this is additive (new preference key, defaults to
   `.system`); reverting the branch fully removes it with no data migration.

## Open Questions

None outstanding — scope, locale identifier, and translation ownership were
confirmed with the user before this design was written.
