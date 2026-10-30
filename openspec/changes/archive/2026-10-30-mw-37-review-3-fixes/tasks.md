## 1. Rules

- [x] 1.1 Write failing rules tests: deleting an edition already gone with a count drop is
      refused; a count update below zero is refused; the race's creator can delete an edition
      left under a race that is gone, another user cannot; deleting a race and its editions
      that are already gone succeeds; a medal with a null finish time and a place with a null
      region are accepted
- [x] 1.2 Change the edition delete rule, add `editionCount >= 0` to `isValidRace`, and accept
      null `result` and `region` (design.md)

## 2. LoadSequence

- [x] 2.1 Write failing `LoadSequenceTests`: an older load applies until a newer one has
      applied, a load may apply in steps, only the newest started load is newest
- [x] 2.2 Add `MedalWall/Shared/UIModels/LoadSequence.swift` and add it to the test target's
      include list

## 3. Newest result wins on every screen

- [x] 3.1 Change the "older load finishes first" tests to expect the older result, still
      loading, and write failing "a newer load fails after an older one loaded" tests, for
      Races, Race Detail, Medals, the You tab, Medal Detail and Search
- [x] 3.2 Move the seven loads onto `LoadSequence`

## 4. Isolation

- [x] 4.1 Mark `RacesViewModel`, `RaceDetailViewModel`, `MedalsViewModel`, `ProfileViewModel`,
      `MedalDetailViewModel` and `EditRaceViewModel` `@MainActor`

## 5. Docs and verify

- [x] 5.1 State the edition limit's gap in the archived `mw-37-review-2-fixes` design
- [x] 5.2 Run `npm test` in `rules-tests/`, the full iOS test suite and lint
- [x] 5.3 `openspec validate mw-37-review-3-fixes --strict`
