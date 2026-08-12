## Context

Distances are kilometre-only throughout. `RaceDistanceCategory.description` returns the
literal strings `"42km"` / `"21km"` / `"10km"` / `"5km"`, and MW-26 explicitly skipped it
during localization on the grounds that it "turns out to be purely numeric — not a
translation target." That assessment was correct for a kilometre-only app and stops being
correct here.

Two device-local preferences already model the pattern this change extends. `AppTheme`
(`@AppStorage("appTheme")` → `.preferredColorScheme` at the root) and `AppLanguage`
(`@AppStorage("appLanguage")` → `.environment(\.locale)` plus `.id(appLanguage)` at the
root) are both enums with a `.system` case, both applied immediately, both unsynced.

The same split MW-26 hit applies here: distance text is built in *both* layers. SwiftUI
views render `Text(distance.displayLabel)`, but `displayLabel` and `description` are plain
`String` computed properties on model types, outside any view body, so they cannot read
`\.locale` or any other environment value. MW-26 solved that with `String.appLocalized`,
which reads the stored preference from `UserDefaults` directly; distance units need the
same treatment.

The constraint that shapes most of the decisions below: Firestore is multi-client by
design — web and Android clients are planned — so the persisted schema must stay
provider-neutral. A unit field on `RaceDistance` would push a display concern into shared
data that every future client would have to honour.

## Goals / Non-Goals

**Goals:**
- A US user sees miles, and a Canadian or Taiwanese user sees kilometres, without either
  touching a setting.
- Distances remain kilometre-canonical in Firestore, byte-identical to what ships today.
- One formatting path serves both distance and pace, under both the unit preference and
  the language preference.
- Adding a further unit later means adding an enum case, not restructuring.

**Non-Goals:**
- Snapping a near-preset custom distance (`42` km, `26.2` mi) to a preset, or prompting
  the user about it.
- Any aggregate-distance surface ("total km run") — none exists today, and achievements
  and profile stats are count- and time-based.
- Changes to distance sorting, equality, hashing, or the Firestore encoding of
  `RaceDistance`.
- Unit conversion of user-entered free text (a race named "Taipei 10K Run" stays as typed).

## Decisions

**1. `DistanceUnit` mirrors `AppLanguage` rather than inventing a pattern.**
```swift
nonisolated enum DistanceUnit: String, CaseIterable {
  case system, kilometers, miles
  static let storageKey = "distanceUnit"
  static func stored(in defaults: UserDefaults = .standard) -> DistanceUnit
  static func resolved(from defaults: UserDefaults = .standard) -> DistanceUnit
}
```
`resolved` never returns `.system` — it collapses to `.kilometers` or `.miles`, so every
call site downstream handles two cases, not three. The `defaults:` parameter exists for
the same reason `AppLanguage` has one: Swift Testing runs tests in parallel, so a test
that mutates `UserDefaults.standard` to check the other unit is a flake waiting to happen.

*Alternative considered:* storing a `Bool` (`usesMiles`). Rejected — it has no way to
express "follow the device", which is the case that makes the feature work without user
action.

**2. `.system` resolves from `Locale.autoupdatingCurrent.measurementSystem`, not from the
app's language preference.**
This is the decision most likely to be got wrong by a later edit, so it is worth stating
plainly: `AppLanguage.resolvedLocale` returns `Locale(identifier: "en")` when the user
pins English. That locale carries **no region**, so its `measurementSystem` is not a
meaningful answer for a US user — it would silently hand them kilometres. The unit follows
the *device region*; the language follows the user's pick; they are independent.

All three `Locale.MeasurementSystem` cases are handled explicitly — `.metric` → km,
`.us` → mi, `.uk` → mi. `.uk` is mixed in general (metric groceries, mile road signs), but
UK road running is miles, so it maps to miles. Not defaulting the switch means a future
fourth case surfaces as a compile error rather than as silent kilometres.

**3. Presets become names; only measurements carry a unit.**
Converting the presets numerically produces `6.2mi` for a 10K and `3.1mi` for a 5K, which
is not how any race in any of the three target markets is branded. Names sidestep this
entirely and translate cleanly (`全馬` / `半馬` / `10K` / `5K` — exactly how Taiwanese
runners write it).

The cost is that with names everywhere, a user whose medals are all presets would never
see the unit change anything. Hence the measurement is shown on the medal detail hero
(`Full · 26.2 mi`), which has room for it, while cards and badges stay compact. The hero
shows both halves unconditionally, including the redundant `10K · 10 km`, because a rule
with no exceptions is cheaper to hold in mind than one with two.

*Alternative considered:* convention-aware labels — `26.2mi` and `13.1mi` for the
marathon distances, but `10K` and `5K` kept as names. Rejected as internally inconsistent:
the badge row would read `26.2mi`, `13.1mi`, `10K`, `5K`, mixing two labelling schemes on
one screen.

**4. `FloatingPointFormatStyle` plus a catalog abbreviation, not `Measurement`/`UnitLength`.**
`Measurement.formatted(.measurement(...))` is the obvious Foundation answer and is wrong
here for two reasons. It formats against the *device* locale, so a user who pinned 繁體中文
on a US device would get mixed output — the same class of bug Decision 2 avoids. And under
`zh-TW` it renders `公里`, which is a copy decision that belongs to the String Catalog and
the user reviewing translations, not to Foundation. So: convert explicitly, format the
number with `FloatingPointFormatStyle` under `AppLanguage.resolvedLocale(from:)`, and
append a catalog-sourced `km` / `mi`. One path, and it is the same path pace already needs.

Conversion uses the exact factor `1.609344`. Display rounds to at most one fraction digit
with the trailing zero dropped (`42.195 → "42.2 km"`, `10 → "10 km"`, `16.09344 → "10 mi"`);
storage never rounds, which is what makes a mile-entered distance round-trip exactly.

**5. Pure `label(in:)` alongside the preference-reading `description`.**
`RaceDistanceCategory` gains `nonisolated func label(in unit: DistanceUnit) -> String`;
`description` stays as the convenience that resolves the stored preference and delegates.
`MedalDetailViewModel` gets the same split for pace. Tests drive the pure function and
never touch global state; production code keeps its existing ergonomics.

**6. The root `.id` becomes a combined language + unit identity.**
`String.appLocalized` and the new unit-aware label functions read `UserDefaults`
non-reactively, so views holding their strings will not invalidate when the preference
changes. MW-26 solved this by keying the root `Group` on `.id(appLanguage)`; this change
widens that key to cover both preferences. The trade-off is inherited rather than new:
changing either preference rebuilds the tree and dismisses the Settings sheet. It is a
rare, deliberate action, and behaving identically for both preferences is better than
having one of them behave specially.

**7. Custom entry converts on save, and an untouched field saves nothing.**
Miles → kilometres round-trips exactly because storage keeps full precision. The reverse
does not: a km-entered `16.09` shown in miles rounds to `10` in the field, and converting
that back yields `16.09344`. Race editions live in the global `races/{id}/editions`
collection and are read by every user, so a save that the user did not intend as an edit
must not rewrite the value. The editor therefore compares the draft against its initial
value and writes only when they differ.

**8. No snapping, no prompt — fix it at entry instead.**
Exact preset matching stays: `42.195` is a Full Marathon and `42.1648128` (26.2 mi) is not.
A tolerance would make `42.0` display as a marathon, which is a claim about the user's race
that the data does not support. A confirmation prompt would be UI spent papering over a
discoverability gap. The actual gap is that a mile-thinking user opens the picker, sees a
row labelled `Full Marathon` with no number on it, and types `26.2` into Custom — so the
picker rows now carry the measurement in the active unit, and the duplicate is never
created. This also makes the four preset literals an explicit cross-platform contract,
which is worth writing down before a web client starts writing race data.

## Risks / Trade-offs

- **[Risk]** `RaceDistanceCategory.description` changing from `"42km"` to `"Full"` is the
  widest blast radius in the change — every card, badge, picker, and preview that renders a
  distance changes text, and nothing about it is type-checked. → **Mitigation:** the
  existing `RaceDistanceCategoryTests` assert the old strings directly, so they fail loudly
  and must be rewritten as part of the task rather than drifting; grep for the hardcoded
  preview strings (`"42km"` in `SurfaceViewModifier`, `"5.31 /km"` and `"5:31 / km"` in the
  medal detail stats previews) as an explicit task step.
- **[Risk]** A user in a metric region who deliberately picks Miles, then travels or
  changes device region, may be surprised by nothing changing. → **Mitigation:** correct
  by design — an explicit pick outranks the device, exactly as `AppLanguage` behaves.
- **[Risk]** A custom `42 km` and a Full Marathon can coexist in one edition, since the
  duplicate guard compares exact kilometre values. → **Mitigation:** accepted, and
  mitigated at entry by Decision 8's picker rows rather than by reconciling stored data.
  Recorded as a non-goal so it is not later mistaken for a bug.
- **[Trade-off]** Users in metric regions lose the numeric badge labels they see today
  (`42km` → `Full`). This affects the existing user base to benefit the new one. Accepted:
  the names are what runners say in all three target markets, and the number is still one
  tap away on the detail screen.

## Migration Plan

1. Add `DistanceUnit` with resolution and formatting, fully unit-tested, touching no UI.
2. Add `DistanceUnitPicker` and the `SettingsView` row; wire `@AppStorage` and the combined
   root `.id` in `MedalWallApp`. At this point the preference exists and applies but nothing
   reads it.
3. Convert `RaceDistanceCategory` to `label(in:)` + delegating `description`, rewriting
   `RaceDistanceCategoryTests` against the new strings.
4. Convert pace, the detail hero, the picker rows, and the custom-distance field.
5. Populate `zh-TW` translations for the new catalog keys; user reviews before merge.

No data migration and no rollback complexity — the change is additive at the storage layer
(one new `UserDefaults` key, defaulting to `.system`) and reverting the branch removes it
entirely, leaving every Firestore document untouched.

## Open Questions

None outstanding. Unit resolution, preset labelling, measurement placement, custom entry
behaviour, and the no-snapping decision were all settled with the user before this design
was written.
