## Why

The code review of MW-37 found two gaps. The Firestore and Storage rules exist only in the
Firebase console, where no one can review, diff or test them, although they are what stops
another user or client from changing a race they did not create. And the Races list can show a
race that was deleted from Race Detail: a load that started before the delete may finish after
the load that started on returning to the list, and its older races replace the newer ones.

## What Changes

- The rules move into the repo as `firestore.rules` and `storage.rules`, referenced from
  `firebase.json` and deployed with the Firebase CLI. The repo becomes their source of truth.
- `rules-tests/` runs both rules files in the Firebase emulators and checks, for the owner,
  another user and a signed-out request, every access the app needs and the ones it must be
  refused. It runs with `npm test` and needs JDK 21 or newer.
- The Races list keeps only the newest load: a load that finishes after a newer one started
  changes neither the list nor the error, and does not end the newer load.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `races`: gains Races List Loading, so a load that finishes after a newer one leaves the newer
  list alone.

## Impact

- **New files:** `firestore.rules`, `storage.rules`, and `rules-tests/` (its `package.json`,
  lock file and test files). `firebase.json` gains `firestore`, `storage` and `emulators`
  sections; `.gitignore` gains the tests' `node_modules` and the emulators' debug logs.
- **Races list:** `RacesViewModel.loadRaces` numbers each load and keeps only the newest.
  `RacesViewModelRepositoryTests` gains the late-load tests.
- **Docs:** `CLAUDE.md` lists the rules test and deploy commands. The archived MW-37 proposal
  and design stop saying the rules live only in the console.
- No app UI, Firestore schema, localization or iOS dependency changes. The rules' behaviour is
  unchanged: the files hold what the console has.
