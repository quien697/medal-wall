## 1. Distance value and unit

- [x] 1.1 Rewrite `RaceDistanceCategoryTests` to fail first: the four constants carry their
      kilometre values; equality uses value and unit (`10 km` equals `.tenKM`, `10 mi` does
      not); `kilometers` converts `10 mi` to `16.09344`; `label` gives `Full` / `Half` /
      `10K` / `5K` whatever the unit setting, and `42.2 km`, `10 mi`, `12.3456 km` and
      `16 km` for custom values, in English and `zh-TW`
- [x] 1.2 Add failing tests for custom validation: `10.1234` is valid; `10.12345`, `0`,
      `-1`, `NaN` and infinity are not
- [x] 1.3 Turn `RaceDistanceCategory` into the `Hashable` struct `{ value, unit }` with
      static standard constants, `kilometers`, a unit-free `label`, and the validation
      check (design.md, Swift model and Custom entry)

## 2. RaceEvent and RaceResult

- [x] 2.1 Rename `RaceDistanceTests` to `RaceEventTests` and make it fail first: encoding
      writes `{ kind: "distance", value, unit, type }`; a missing or other `kind`, and a
      missing or unknown `unit`, fail to decode; `==` and `hash` use category and type but
      not `id`; `<` orders by type, then real length longest first, then kilometres before
      miles at equal length
- [x] 2.2 Add failing `RaceResultTests`: `.seconds(13500)` encodes
      `{ value: 13500, unit: "seconds" }`, and an unknown unit fails to decode
- [x] 2.3 Rename `RaceDistance` to `RaceEvent` (`git mv` to `RaceEvent.swift`) across the app
      and tests, and rename `RaceEntry.distance` to `event`
- [x] 2.4 Add `RaceResult` and `ResultUnit` in `RaceResult.swift`
- [x] 2.5 Update the test target's `membershipExceptions` in `project.pbxproj` for
      `RaceEvent.swift` and `RaceResult.swift`

## 3. Stored fields

- [x] 3.1 Add failing tests in `MedalFirestoreRepositoryTests`: an encoded medal has `event`
      and `result` and no `distance` or `finishTime`; a medal without a time has no
      `result`; clearing the time on update deletes `result`; `medalUpdateFields` names
      `event` and `result`
- [x] 3.2 Add failing tests in `RaceFirestoreRepositoryTests`: an encoded edition has `events`
      and no `distances`, and the edition's update field list names `events`
- [x] 3.3 Rename `Medal.distance` to `event` and replace `Medal.finishTime` with
      `result: RaceResult?`; `recordedFinishTime` reads `result?.value` with its guards
      unchanged
- [x] 3.4 Rename `RaceEdition.distances` to `events`, and add the `///` comments for
      `Medal.event` and `RaceEdition.events` (design.md, Firestore shape)
- [x] 3.5 Update both repositories' field lists, then the sample data and previews,
      including `MedalDetailInfoSection`'s preview text

## 4. Pace

- [x] 4.1 Add failing tests: a `10 mi` medal at 1:10:00 reads `7'00" /mi` in miles and
      `4'20" /km` in kilometres; `5'41" /km` still reads `9'08" /mi`; a zero, infinite or
      `NaN` distance still gives no pace
- [x] 4.2 Make `averagePace` take the active unit and calculate in it, and make
      `paceValueText` / `paceText` take minutes per that unit (design.md, Pace); update
      `MedalDetailViewModel` and `MedalPersonalBestCarousel`

## 5. Grouping

- [x] 5.1 Rewrite the filter and record tests to fail first (`MedalDistanceFilteringTests`,
      `MedalDistanceFilterTests`, `MedalPersonalRecordTests`, `MedalPersonalBestTests`):
      `10K` and `10 mi` are separate options with separate records and ids; `42.2 km` is
      its own option, ordered before `Full`; a value that used to fold into `Full` now
      stays separate
- [x] 5.2 Remove `nearestPreset`, key filters and records on the category, and make
      `MedalDistanceFilter`'s `==`, `hash` and `id` use value and unit

## 6. Custom entry

- [x] 6.1 Add failing tests in `EditRaceEditionViewModelTests`: `addDistance` refuses
      `10.12345`, `0` and `NaN` with `invalidDistance`, keeps a `10 mi` next to a `10K`, and
      refuses a custom `10 km` beside a `10K` as a duplicate
- [x] 6.2 Add failing tests in `EditMedalViewModelTests`: `selectDistance(_:)` refuses an
      invalid custom distance with `invalidDistance` and accepts a valid one; `isFormValid`
      uses the same rule
- [x] 6.3 Implement the validation in `addDistance` and the new `selectDistance(_:)`, and call
      `selectDistance` from `EditMedalView`'s distance picker
- [x] 6.4 Rebuild `EditDistanceView` custom entry: a "Custom is chosen" state, the number
      field with a unit-free label, the Kilometers / Miles switch starting at the stored or
      the resolved unit, and preset rows showing their stored measurement; add named
      previews for a new custom distance and for a stored custom distance in miles
- [x] 6.5 Update the `invalidDistance` message and recovery text to the four-decimal wording
      in design.md

## 7. DistanceUnit

- [x] 7.1 Rewrite `DistanceUnitTests`: drop the tests for the removed conversions, and test
      that `formatted` shows the stored value in its own unit with up to four decimals
- [x] 7.2 Remove `displayValue(fromKilometers:)`, `kilometers(fromDisplayValue:)`,
      `roundedDisplayValue`, `customKilometers` and `customFieldLabel`, and make
      `formatted` stop converting

## 8. Settings

- [x] 8.1 Add the Preferences footer to `SettingsView` in `Font.TypeScale.caption` and
      `Color.Text.secondary`, with the text from design.md

## 9. Strings

- [x] 9.1 Script the new String Catalog keys with `zh-TW`: the Settings footer, the unit-free
      custom label, and the updated invalid-distance texts; remove
      `"Custom distance (%@)"`
- [x] 9.2 Update `LocalizedDisplayStringTests` for the changed and removed keys

## 10. Verify

- [x] 10.1 Search the code for leftovers: `nearestPreset`, `customKilometers`,
      `roundedDisplayValue`, `.custom(`, a stored `finishTime`, and `RaceDistance` other
      than `RaceDistanceCategory` / `RaceDistanceType`
- [x] 10.2 Build with SwiftLint clean, then run the full test suite
- [x] 10.3 Check the medal rows, filter chips, personal best cards, distance picker and
      Settings in previews, in English and 繁體中文, with each unit setting, including a
      four-decimal custom label
- [x] 10.4 After the development documents are rewritten to the new shape, launch the app
      against them

## 11. Docs

- [ ] 11.1 Update `CLAUDE.md`'s data model notes: `RaceEvent` instead of `RaceDistance`, and
      `RaceEntry` bundling a `RaceEvent`
- [ ] 11.2 When archiving, rewrite the `distance-units` spec's Purpose, which still describes
      kilometre storage and display conversion
