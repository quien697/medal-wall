## Context

Today a distance is `RaceDistance { category: RaceDistanceCategory, type }`, stored as
`{ value, type }` with `value` always in kilometres. `RaceDistanceCategory` is an enum of
four presets plus `.custom(Double)`. `DistanceUnit` converts kilometres to miles for display
and back for entry, `nearestPreset` folds near-preset values into a preset for filter chips
and personal bests, and `customKilometers` stops an unedited save from rewriting a
converted value. The proposal explains why this goes; the specs state the new behaviour.

There is no real data and no other client yet. Planned web, Android and admin clients will
read the same documents, so the stored shape is the part that is expensive to change later.
Swift names and structure live only in this app and stay cheap to change.

## Goals / Non-Goals

**Goals:**
- Store every distance with its unit, and show exactly what is stored.
- Name the stored fields so a later timed race (a fixed time whose result is a distance)
  fits without renaming anything: `event`, `result`, `events`, and `kind`.
- Keep the Swift code as simple as distance races need.

**Non-Goals:**
- Timed, relay and trail races. Nothing in this change reads or writes `kind: "time"`.
- Migrating existing documents. The development data is rewritten by hand.
- `race-catalog`, which is updated separately to write the new shape.
- On-screen labels. "Distance", "Finish Time" and the standard distance names stay.

## Decisions

### Firestore shape

```
// medals/{id}
event:  { kind: "distance", value: 42.195, unit: "kilometers", type: "inPerson" }
result: { value: 13500, unit: "seconds" }          // absent when no time is recorded

// races/{raceId}/editions/{id}
events: [ { kind: "distance", value: 10, unit: "miles", type: "virtual" } ]
```

- A medal's `event` is the event it was earned in: a distance and how it was run. An
  edition's `events` are the events that edition offers. Picking one when adding a medal
  copies it into the medal's `event`, so the medal keeps its own copy. The same two
  sentences go on the Swift properties as `///` comments.
- `kind` sits on the event only. The event decides what its result means; a second `kind`
  on the result could disagree with it.
- `unit` reuses `DistanceUnit`'s raw values, which the distance unit setting already
  stores. Results get their own unit type, `ResultUnit`, holding only `seconds`.

### Swift model

- `RaceDistance` is renamed `RaceEvent` (file `RaceEvent.swift`). It keeps `id`,
  `category: RaceDistanceCategory` and `type: RaceDistanceType`. It has no `kind` property:
  its `Codable` writes `kind: "distance"` and requires that value when decoding. The
  property arrives with the first second kind, when the compiler will point at every place
  that needs to tell the two apart.
- `RaceDistanceCategory` becomes a `Hashable` struct `{ value: Double, unit: DistanceUnit }`.
  `.full`, `.half`, `.tenKM` and `.fiveKM` become static constants in kilometres, so
  `category == .full` keeps working for profile counts and achievements, and a custom value
  equal to a standard one is that standard by plain equality. A computed `kilometers`
  converts a mile value for sorting and pace, in memory only.
- `RaceEvent`'s `==` and `hash` compare `category` and `type`, leaving out `id`. `<` sorts by
  type, then by `kilometers` from longest to shortest, then kilometres before miles where two
  real lengths are equal, so the order never depends on what Firestore returned.
- `Medal.distance` becomes `event: RaceEvent`, and `Medal.finishTime` becomes
  `result: RaceResult?`. `RaceResult` is a `Codable` struct `{ value: Double, unit:
  ResultUnit }` with a `static func seconds(_:)` factory, so call sites and tests read
  `result: .seconds(13500)`. `recordedFinishTime` reads `result?.value` and keeps its
  existing guards.
- `RaceEdition.distances` becomes `events: [RaceEvent]`, and `RaceEntry.distance` becomes
  `event`.
- View models and views keep the names `distance`, `distances` and `finishTime`, because
  those follow the on-screen labels ("Distance", "Finish Time").
- The field lists `MedalFirestoreRepository.medalUpdateFields` and the edition list in
  `RaceFirestoreRepository` name `event`, `result` and `events`.

### Display

- `RaceDistanceCategory.label` no longer takes a unit. A standard distance returns its name
  from the String Catalog. Any other returns its measurement: the stored number with up to
  four fraction digits under the app language's locale, plus the `km` / `mi` abbreviation.
  The distance picker's preset rows use the same measurement text, so they read
  `42.195 km` in both units.
- `DistanceUnit` loses `displayValue(fromKilometers:)`, `kilometers(fromDisplayValue:)`,
  `roundedDisplayValue`, `customKilometers` and `customFieldLabel`. `formatted` takes the
  stored value in its own unit and no longer converts.

### Pace

Pace is calculated in the unit it is shown in. When the event's unit matches the active unit,
the stored value is used as it is; only a mismatch converts. A `10 mi` event at 1:20:00 then
reads exactly `8'00" /mi`. Converting to kilometres and back can land on 7.9999… minutes,
and because pace truncates seconds that would show as `7'59"`. `averagePace` therefore takes
the active unit, and `paceValueText` / `paceText` take minutes per that unit, keeping their
existing guards against values that would trap `Int(_:)`.

### Custom entry

- `EditDistanceView` keeps a separate "Custom is chosen" state instead of deriving it from
  the category. Otherwise typing `42.195` would turn the selection into the Full Marathon
  row and hide the field mid-entry. On confirm, the category is built from the number and
  the switch, and equality makes an exact standard value that standard.
- The switch is a segmented Kilometers / Miles picker under the number field. It starts at
  the stored unit for a stored custom distance, otherwise at `DistanceUnit.resolved()`. The
  field's label drops its unit, since the switch now shows it.
- A custom distance is valid when it is greater than zero, finite, and has at most four
  decimals. The decimal check allows for binary rounding: the value is compared with itself
  rounded to four decimals, with a tolerance of `1e-9`, because `10.1234 × 10_000` is not
  exactly an integer as a `Double`.
- Both callers refuse an invalid distance with `AppError.invalidDistance` when the picker
  confirms. The edition flow does this already in `addDistance`; the medal flow gains a
  throwing `selectDistance(_:)` on `EditMedalViewModel`. The error's texts mention the
  four-decimal limit:

  | | English | zh-TW |
  |---|---|---|
  | Message | Distance must be greater than zero, with at most 4 decimal places. | 距離必須大於零，且最多 4 位小數。 |
  | Recovery | Please enter a distance greater than 0, with up to 4 decimal places. | 請輸入大於 0 且最多 4 位小數的距離。 |
  | Field label | Custom distance | 自訂距離 |

### Grouping

`nearestPreset` goes. `distanceCategoriesOwned`, `filtered(by:)` and `personalRecords` key on
the category itself. `MedalDistanceFilter`'s `==`, `hash` and `id` use value and unit, with
`id` as `"\(value)-\(unit.rawValue)"`. Ordering uses `RaceEvent`'s real-length rule.

### Settings

The Preferences section gets a footer, set in `Font.TypeScale.caption` and
`Color.Text.secondary`:

- EN: "Distance sets the pace unit (/km or /mi) and the starting unit for a custom distance.
  Distances always show as they were entered."
- zh-TW: 「距離」設定配速單位（/公里 或 /英里）及自訂距離的預設單位。距離一律依輸入時的單位顯示。

The zh-TW text names the units as the app shows them in that language: `km` and `mi` are
`公里` and `英里` there.

### Strings and project file

- New String Catalog keys: the Settings footer, the custom field's unit-free label, and the
  updated invalid-distance texts, each with `zh-TW`. `"Custom distance (%@)"` is removed.
  Keys are added by script, in `localizedStandardCompare` order, because `xcodebuild` does
  not add them.
- `project.pbxproj`: `RaceEvent.swift` replaces `RaceDistance.swift`, and `RaceResult.swift` is
  added, in the test target's `membershipExceptions` list. Without that, the test build fails
  with errors that do not point at the list.

## Risks / Trade-offs

- [Documents in the old shape no longer decode] → The development data is rewritten by hand
  before running this build, and `race-catalog` output is updated separately.
- [Long custom labels such as `12.3456 km` on compact tags] → Accepted; four decimals stay.
- [Firebase security rules are not written yet] → When they are, they must allow `event`,
  `result` and `events`, and refuse a distance without a `unit`; the list of rules to
  write records this.
- [The renames touch about fifty files] → They are mechanical; the compiler finds every use,
  and the full test suite runs after each step.

## Migration Plan

1. Merge into `develop` after the full test suite passes.
2. Rewrite the development documents to the new shape by hand before running the build
   against them.
3. Rollback is a revert of the merge; documents already rewritten would then need to be put
   back by hand.
