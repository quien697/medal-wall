## Why

The second MW-37 code review found gaps in the security rules that the app's own checks cannot
cover. Races are a shared collection, and the rules check too little of a race: one race
document any signed-in user writes without a `name`, or with a date stored as text, makes the
Races list and Search fail for every user. The review also found that a race with 500 or more
editions cannot be deleted under the rules, although the races spec promises it can. No real
race comes close: an edition is one year.

## What Changes

- **Races and editions must be readable:** the Firestore rules refuse a race or edition missing
  a field the app needs to read it, or holding one of the wrong type.
- **A race already gone can be deleted:** deleting a race that another device already deleted
  succeeds instead of failing on a document that no longer exists.
- **An edition update leaves the count alone:** the rules refuse an edition update committed
  with a change to its race's `editionCount`.
- **Race files only at the app's logo paths:** Storage accepts race files only at the four
  logo paths the app writes, not anywhere under `races/{raceId}/`.
- **A race holds at most 200 editions:** the rules refuse an edition past 200, and Edit Race
  disables Add in the Editions section at 200, with a note saying so. A race's delete therefore
  always fits one commit, so the batching for 500 or more editions goes.
- **Every screen keeps its newest load:** Race Detail (its editions, and the race after Edit
  Race closes), the Medals list, the You tab and Medal Detail (after Edit Medal closes) behave
  as the Races list and Search already do. A load that finishes after a newer one has started
  changes nothing, so an edition or medal just deleted or edited no longer goes back to an
  older state when an older load lands last.
- **Docs:** the archived `mw-37-review-fixes` design states the test runner's
  `--test-concurrency=1` flag and why it is needed, and no longer lists a count change without
  its edition among the refusals: the race's rule cannot see whether its edition was written.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `races`: Race Management deletes a race in one commit and succeeds when the race is already
  gone, and loses the scenario for 500 or more editions. Edition Count Integrity refuses an
  edition update that changes the count. New: Edition Limit (200 editions), Shared Race Data
  Stays Readable, and Race Detail Loading.
- `medal-browsing`: New: Medal List Loading.
- `profile`: New: You Tab Loading.
- `medal-detail`: New: Medal Detail Reload.
- `persistence-integrity`: Atomic Multi-Document Writes drops its exception for a race delete
  larger than one batch, and its scenario for 500 or more editions.

## Impact

- **Rules:** `firestore.rules` (race and edition field checks, race delete, edition update,
  edition limit) and `storage.rules` (race logo paths), with new cases in `rules-tests/`.
- **Edit Race:** `EditRaceViewModel` gains whether another edition fits;
  `EditRaceEditionSection` disables Add and shows the note; `Race` holds the limit.
- **Repository:** `RaceFirestoreRepository.deleteRace` commits one batch;
  `deletionChunks`, `batchLimit` and their tests go.
- **Loads:** `RaceDetailViewModel` (`loadEditions`, `loadRace`), `MedalsViewModel`,
  `ProfileViewModel` and `MedalDetailViewModel.reloadMedal` number each load. The stubs'
  `fetchEditions`, `fetchRace` and `fetchMedal` answer with what was stored when they started,
  and the last two can be held.
- **Localization:** one new string, "A race can have up to %lld editions.", with zh-TW.
- No Firestore schema, design-token or dependency changes.
