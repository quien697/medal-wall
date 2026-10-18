## Why

Every distance is stored in kilometres and converted for display, so what is saved and what
is shown can differ. A custom `26.2` typed in miles mode is saved as `42.1648128` km, which
display rounds and the filter chips fold into `Full`. A stored `42.195` reads as `42.2 km`
or `26.2 mi`. Editing a custom distance in the other unit needs special logic
(`customKilometers`) so that saving without a change does not rewrite it.

The stored field names also only fit distance races. A later version may record timed
races, such as 24H, where the time is fixed and the distance is the result. There is no
real data yet and no other client, so this is the cheapest moment to change the stored
shape. Tracked in Jira [MW-34](https://quien.atlassian.net/browse/MW-34).

## What Changes

- **BREAKING (Firestore):** a medal's `distance` becomes `event: { kind, value, unit, type }`
  and its `finishTime` becomes an optional `result: { value, unit }`. A race edition's
  `distances` becomes `events: [{ kind, value, unit, type }]`. `kind` is `"distance"`, an
  event's `unit` is `"kilometers"` or `"miles"`, and a result's `unit` is `"seconds"`.
  Existing documents are not migrated; the development data is updated by hand.
- A distance is stored in the unit it was entered in and shown exactly as stored. Nothing
  converts a distance between kilometres and miles for storage or display.
- The four standard distances are `42.195`, `21.0975`, `10` and `5` kilometres. They keep
  their names (`Full`, `Half`, `10K`, `5K`) in both units, and the distance picker's preset
  rows show their stored measurement, such as `42.195 km`, in both units.
- Every other distance shows its stored number and unit, such as `42.2 km` or `10 mi`, with
  up to four decimals and trailing zeros dropped.
- A custom distance is entered as a number plus a kilometres/miles switch that starts at the
  distance unit setting. The value must be greater than 0, a finite number, and have at
  most four decimals. A value equal to a standard distance saves that standard distance.
- The distance unit setting controls only how pace is expressed and where the custom switch
  starts. Settings states this under the Preferences section.
- Filter options, personal bests, equality and the edition duplicate check match a distance
  by its exact value and unit. Nothing is snapped to a nearby standard distance, so
  `10 km` and `10 mi` are separate distances. Sorting compares real length.
- Pace is calculated from the real length of the distance, in either unit.
- Swift: `RaceDistance` becomes `RaceEvent`. The properties become `medal.event`,
  `medal.result` and `edition.events`. `RaceDistanceCategory` becomes a value and a unit,
  with the standard distances as constants. `nearestPreset`, `customKilometers`,
  `roundedDisplayValue` and the `.custom` case are removed. On-screen labels such as
  "Distance" and "Finish Time" do not change.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `distance-units`: distances are stored with their unit in the `event` / `result` shape
  instead of in kilometres; a measured distance shows its stored value with up to four
  decimals; pace is calculated from the real length; the unit setting no longer decides how
  a distance is shown.
- `settings`: the distance unit preference applies to pace and the custom entry's starting
  unit only, and Settings describes that.
- `races`: a custom distance is entered and stored in its own unit through a switch; the
  picker's preset rows show the stored measurement; the duplicate check compares value and
  unit.
- `medal-browsing`: filter options and personal bests are grouped by exact value and unit,
  and ordered by real length.

## Impact

- Models: `RaceDistance.swift` (renamed `RaceEvent`), `RaceDistanceCategory.swift`,
  `Medal.swift`, `RaceEdition.swift`, `Medal+Computed.swift`, `Medal+Stats.swift`, and a new
  result type for `medal.result`.
- `DistanceUnit.swift`: the conversion helpers for display and entry go; pace and the
  real-length conversion stay.
- Browsing: `Medal+Browsing.swift`, `MedalDistanceFilter.swift`, `MedalPersonalBest.swift`.
- Entry: `EditDistanceView.swift`, `EditMedalViewModel.swift`,
  `EditRaceEditionViewModel.swift`, `DraftRaceEdition.swift`, the views that pass a distance
  label, and `SettingsView.swift`.
- `MedalFirestoreRepository.medalUpdateFields` lists the new field names.
- `Localizable.xcstrings`: the Settings description and the switch's labels, with `zh-TW`.
- Sample data, `project.pbxproj` (the test target's file list), and about twenty test files
  that build distances or finish times.
- Firebase security rules, kept in the console rather than this repo, must allow the new
  fields before release. `race-catalog` is updated separately to write the new shape.
- Unchanged: achievements and profile counts (they already match the standard distances
  exactly), the medal detail facts list, and every on-screen label.
