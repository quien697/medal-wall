## Why

A strict third review of MW-37 found that the edition rules can still let `editionCount` drift
from the real number of editions, that editions left under a deleted race can never be
removed, and that the rules refuse a null finish time or region that every client reads as
none. It also found that "newest load wins" throws away a fresher result when the newest load
then fails, so a first load can end on an error and an empty screen although data arrived.
That rule is now copied in seven places.

## What Changes

- **The edition count stays true:** deleting an edition that is already gone can no longer
  lower the count, and the count can never go below zero.
- **Leftover editions can be removed:** once a race is gone, its creator can delete the
  editions left under it, and deleting editions that are already gone succeeds. A race deleted
  on another device while this one deletes it no longer ends in a delete error.
- **Null optionals are accepted:** a medal's finish time and a place's region may be null, as
  a race's photo and website already may.
- **The edition limit says what it checks:** the backend checks the count a commit leaves, so
  every client adds one edition per commit with its count change.
- **Newest result wins, on every screen:** a load's result shows unless a newer one has already
  shown, and only the newest load presents an error or ends the loading state. One helper,
  `LoadSequence`, holds the rule for all seven loads.
- **View models with overlapping-load tests are explicitly `@MainActor`,** as `SearchViewModel`
  already is, because the test module has no default actor.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `races`: Race Management (deleting a race that another device deletes meanwhile), Edition
  Count Integrity (a delete of an edition already gone), Edition Limit (what the backend
  checks), Races List Loading and Race Detail Loading (newest result wins).
- `medal-browsing`: Medal List Loading (newest result wins).
- `profile`: You Tab Loading (newest result wins).
- `medal-detail`: Medal Detail Reload (newest result wins).
- `search`: Search Data Loading (newest result wins).

## Impact

- **Rules:** `firestore.rules` (edition delete, count floor, null optionals), with new cases in
  `rules-tests/firestore.test.js`.
- **Loads:** new `MedalWall/Shared/UIModels/LoadSequence.swift`, used by `SearchViewModel`,
  `RacesViewModel`, `RaceDetailViewModel` (editions and race), `MedalsViewModel`,
  `ProfileViewModel` and `MedalDetailViewModel`; the "older load finishes first" tests change
  to the new rule.
- **Isolation:** explicit `@MainActor` on `RacesViewModel`, `RaceDetailViewModel`,
  `MedalsViewModel`, `ProfileViewModel`, `MedalDetailViewModel` and `EditRaceViewModel`; no
  change in the app, whose module defaults to the main actor.
- **Docs:** the archived `mw-37-review-2-fixes` design states the edition limit's gap.
- No Firestore schema, localization, design-token or dependency changes.
