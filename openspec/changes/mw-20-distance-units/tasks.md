## 1. Unit Model & Resolution

- [x] 1.1 Write failing tests for `DistanceUnit`: `stored(in:)` returns the stored
      case, and falls back to `.system` when the key is unset or holds an
      unrecognized raw value (inject a scratch `UserDefaults`, never `.standard`)
- [x] 1.2 Write failing tests for `resolved(from:)`: `.kilometers` and `.miles`
      pass through unchanged, and `.system` collapses to a concrete case — it must
      never return `.system`
- [x] 1.3 Write failing tests for measurement-system mapping covering all three
      `Locale.MeasurementSystem` cases: `.metric` → kilometres, `.us` → miles,
      `.uk` → miles (per design.md Decision 2)
- [x] 1.4 Implement `DistanceUnit` (`Shared/UIModels/DistanceUnit.swift`),
      mirroring `AppLanguage.swift`'s structure — `nonisolated enum`, `storageKey`,
      `stored(in:)`, `resolved(from:)`, `label`
- [x] 1.5 Verify by inspection that `.system` resolution reads
      `Locale.autoupdatingCurrent.measurementSystem` and **not**
      `AppLanguage.resolvedLocale` — a pinned `Locale(identifier: "en")` carries no
      region and would hand a US user kilometres. Handle `.metric`, `.us`, and
      `.uk` explicitly; `Locale.MeasurementSystem` is a struct rather than an enum,
      so the compiler requires a `default` — fall back to kilometres

## 2. Conversion & Formatting

- [x] 2.1 Write failing tests for kilometre↔mile conversion using the exact factor
      `1.609344`: `10` mi → `16.09344` km, and the reverse round-trips exactly
- [x] 2.2 Write failing tests for display formatting: `42.195` → `"42.2 km"` /
      `"26.2 mi"`, `21.0975` → `"21.1 km"` / `"13.1 mi"`, `10` → `"10 km"` (trailing
      zero dropped) / `"6.2 mi"`, `16.09344` → `"16.1 km"` / `"10 mi"`
- [x] 2.3 Write failing tests for out-of-range values per the project's guard
      convention: zero and negative distances format without crashing or producing
      a malformed string
- [x] 2.4 Implement conversion and formatting on `DistanceUnit` using
      `FloatingPointFormatStyle` with `AppLanguage.resolvedLocale(from:)`, plus a
      String Catalog abbreviation — explicitly not `Measurement`/`UnitLength`
      (design.md Decision 4). Give the formatting helper a `defaults:` parameter
      like `String.appLocalized` has, so a test can vary the language without
      mutating `UserDefaults.standard`
- [x] 2.5 Add `km` and `mi` abbreviation keys to `Localizable.xcstrings` (English
      source; `zh-TW` filled in at task 7.1)

## 3. Settings UI & Root Wiring

- [x] 3.1 Build `DistanceUnitPicker` (`Features/Setting/`) mirroring
      `LanguagePicker`, with named `#Preview`s per project convention
- [x] 3.2 Add the "Distance" row to `SettingsView`'s Preferences section, below
      `LanguagePicker`
- [x] 3.3 Add `@AppStorage(DistanceUnit.storageKey)` to `MedalWallApp` and widen the
      root `.id(appLanguage)` to a combined language + unit identity
- [x] 3.4 Manually verify: switching the picker updates displayed distances
      immediately without relaunch, and the preference survives a restart —
      verified on a physical device by Quien

## 4. Preset Naming

- [x] 4.1 Rewrite `RaceDistanceCategoryTests` against the new labels — the existing
      tests assert `"42km"` / `"21km"` / `"10km"` / `"5km"` and must fail first.
      Cover all four presets plus custom values in both units via `label(in:)`
- [x] 4.2 Implement `nonisolated func label(in unit: DistanceUnit) -> String` on
      `RaceDistanceCategory`: presets return short names (`Full`, `Half`, `10K`,
      `5K`), custom returns a formatted measurement
- [x] 4.3 Reduce `description` to a convenience that resolves the stored preference
      and delegates to `label(in:)`, keeping existing call sites unchanged
- [x] 4.4 Add the short preset names and the long picker forms (`Full Marathon`,
      `Half Marathon`) to `Localizable.xcstrings` as separate keys — no work needed:
      all six keys already exist from MW-26, with `Full`/`Half` already translated
      as `全馬`/`半馬` (the profile stat cards use them for the same meaning) and
      `10K`/`5K` marked `shouldTranslate: false`
- [x] 4.5 Verify `RaceDistance.displayLabel` composes correctly for non-in-person
      types — `"Virtual Half"`, not `"Virtual 21km"`
- [x] 4.6 Confirm sorting, equality, and hashing still key off `category.value` and
      are untouched by the label change (existing `RaceDistanceTests` must pass
      unmodified)

## 5. Distance & Pace Display

- [x] 5.1 Write failing tests for `MedalDetailViewModel` pace text in both units:
      a 5'41" /km pace renders as `5'41" /km` and `9'08" /mi`
- [x] 5.2 Implement pace as a pure helper taking the unit plus a thin computed
      property on the ViewModel, so tests never mutate `UserDefaults.standard`
      (design.md Decision 5 — Swift Testing runs in parallel)
- [x] 5.3 Write failing tests for the medal detail hero string: `Full · 42.2 km` /
      `Full · 26.2 mi`, and the deliberately redundant `10K · 10 km` in km mode
- [x] 5.4 Implement the hero distance text on `MedalDetailViewModel` and update
      `MedalDetailView` / `MedalDetailHeroSection` to consume it, keeping derived
      values out of the view per project convention
- [x] 5.5 Update the hardcoded preview strings: `"5.31 /km"` in
      `MedalDetailStatsGridItem`, `"5:31 / km"` in `MedalDetailStatsSection`, and
      `"42km"` in `SurfaceViewModifier`

## 6. Custom Distance Entry

- [x] 6.1 Add each preset's measurement in the active unit to the `EditDistanceView`
      picker rows (`Full Marathon · 26.2 mi`), so a mile-thinking user taps the
      preset instead of typing the number into Custom
- [x] 6.2 Make the custom field label unit-aware (`Custom distance (mi)`) and
      convert entered values to kilometres at full precision on save
- [x] 6.3 Write a failing test for the no-op edit case: a distance stored as `16.09`
      km, opened in miles mode and saved without the field being edited, keeps
      `16.09` — race editions are shared records and must not drift
- [x] 6.4 Implement the draft-versus-initial comparison that makes 6.3 pass
- [x] 6.5 Drop the hardcoded unit from `AppError`: "Please enter a distance greater
      than 0 km." → "Please enter a distance greater than 0."
- [x] 6.6 Confirm no snapping or confirmation prompt was introduced — a custom
      `26.2` mi stays `42.1648128` km and remains custom (design.md Decision 8)

## 7. Translations & Verification

- [x] 7.1 Populate `zh-TW` translations for every new catalog key — `全馬`, `半馬`,
      `10K`, `5K`, the unit abbreviations, and the "Distance" picker label — for
      user review before merge
- [x] 7.2 Run the full test suite and confirm it passes
- [x] 7.3 Build and manually verify each unit end to end: preset badges, detail
      hero, custom entry, pace, and the picker rows, in both units and both
      languages — verified on a physical device by Quien
- [ ] 7.4 At archive time, extend the `settings` capability `Purpose` sentence,
      which currently enumerates only the appearance mode and the app language, to
      include the distance unit — the archive skill only prompts on a `TBD` Purpose,
      so this would otherwise go stale silently
- [x] 7.5 Update `docs/development-workflow.md`, which states the `openspec` CLI is
      not installed — it is, and this change was created with it

## 8. Two-Option Rework

Retire the `System` case after review: `"system"` is an ambiguous value to persist across
devices and clients, and a measurement system is not a live OS setting worth following
continuously. The device seeds the initial value instead.

- [x] 8.1 Update the `distance-units` and `settings` spec deltas: two options, device
      seeding before any choice, and the rule that only a concrete unit is ever stored
- [x] 8.2 Record the reversal in `design.md` Decision 1, with the reasoning that retired
      the `.system` case, so the change history explains itself
- [x] 8.3 Rewrite the `DistanceUnit` resolution tests: `stored(in:)` returns optional,
      `resolved(from:)` falls back to `deviceDefault`, an explicit choice outranks the
      device, and a legacy persisted `"system"` is not honoured as a unit
- [x] 8.4 Reduce `DistanceUnit` to `kilometers` / `miles` with a `deviceDefault`; the
      `concrete` indirection disappears because every case is now concrete
- [x] 8.5 Seed both `@AppStorage` declarations from `.deviceDefault` and update the
      `DistanceUnitPicker` previews
- [x] 8.6 Run the full suite and SwiftLint
