## Why

The app expresses every distance in kilometres, with no way to change it. The target
markets are Canada, the USA, and Taiwan; US runners think in miles, so a US user reading
"42km" and a pace of "5'41\" /km" is doing arithmetic the app should be doing for them.
Tracked in Jira [MW-20](https://quien.atlassian.net/browse/MW-20).

## What Changes

- Add a "Distance" row to `SettingsView`'s Preferences section, next to `LanguagePicker`:
  Kilometers / Miles. Selecting a unit applies it immediately.
- Seed the initial value from the **device region's** measurement system, so Canada and
  Taiwan get kilometres and the USA gets miles without the user touching the setting. The
  picker deliberately has no System option, unlike Appearance and Language: only a
  concrete unit is ever stored, so the value is unambiguous on any device or client.
- **BREAKING (display only):** preset distances stop rendering as numbers on cards and
  badges. `42km` / `21km` / `10km` / `5km` become `Full` / `Half` / `10K` / `5K` in both
  units — the names runners actually use, and the only labels that read correctly in
  miles without turning a 10K into a "6.2mi race".
- Show the measured distance, in the active unit, on the three surfaces that have room
  for it: the preset picker rows, the medal detail hero, and every custom distance.
- Express average pace per the active unit — `5'41" /km` or `9'08" /mi`.
- Accept custom distance entry in the active unit: in miles mode the field reads
  `Custom distance (mi)` and converts to kilometres for storage.
- No Firestore schema change. Distances stay kilometre-canonical, so the planned web and
  Android clients read exactly the same numbers they do today.

## Capabilities

### New Capabilities
- `distance-units`: How a distance value becomes displayed text — the stored unit
  preference and how the device seeds it, the kilometre-canonical storage rule, conversion
  and formatting precision, the naming rule that presets are names rather than converted
  numbers, and which surfaces carry a unit.

### Modified Capabilities
- `settings`: Adds a Distance Unit preference (Kilometers / Miles) alongside the existing
  Appearance and Language preferences — same storage/apply/sync-scope pattern: stored
  locally via `@AppStorage`, applied immediately, not synced across devices. Unlike those
  two it has no System option; the device seeds the initial value instead.
- `races`: Custom distances in a race edition are entered in the user's active unit and
  converted to kilometres for storage, with an unedited field saving its original value
  untouched. Adds the rule that a near-preset custom distance is never snapped or
  queried, and that the picker instead surfaces each preset's measurement so the
  duplicate is avoided at entry.

## Impact

- New `DistanceUnit` (`Shared/UIModels/`) and `DistanceUnitPicker`
  (`Features/Setting/`), mirroring `AppLanguage` and `LanguagePicker`.
- `SettingsView.swift` — new "Distance" row.
- `MedalWallApp.swift` — new `@AppStorage`; the root `.id(appLanguage)` becomes a
  combined language + unit identity so a unit change re-renders the tree.
- `RaceDistanceCategory.swift` — `description` stops returning `"42km"`; gains a pure
  `label(in:)`. This is the widest blast radius: every card, badge, and picker that
  renders a distance changes text.
- `EditDistanceView.swift` — unit-aware custom field and preset rows.
- `MedalDetailViewModel.swift`, `MedalDetailView.swift`, `MedalDetailHeroSection.swift` —
  unit-aware distance and pace text.
- `AppError.swift` — the "greater than 0 km" message drops its hardcoded unit.
- `Localizable.xcstrings` — new keys for the short preset names, the unit abbreviations,
  and the picker label, with `zh-TW` translations (`全馬` / `半馬`).
- No changes to the Firestore schema, `Medal`, `Race`, `RaceEdition`, `RaceDistance`
  encoding, sorting, equality, hashing, achievements, or profile stats.
