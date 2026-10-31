## Context

The Firestore and Storage rules published for MW-37 were pasted into the Firebase console by
hand. The repo already has a Firebase CLI setup for Hosting: `firebase.json` with a `hosting`
section only, and `.firebaserc` naming the project `medal-wall-4697`. Nothing in the repo runs
the rules.

The Races list loads its races in `RacesView`'s `.task` each time the list appears, and again
in an unstructured `Task` when the Add Race sheet closes. `RacesViewModel.loadRaces` assigns
whatever its fetch returns, so two loads can overlap and the one that started first can finish
last. Search had the same gap and closed it with a load counter in `SearchViewModel`.

## Goals / Non-Goals

**Goals:**
- The rules are files in the repo, deployed from it, and tested against the emulators.
- The tests prove both what the app needs to do and what other users and signed-out requests
  are refused.
- The Races list never shows the result of a load that a newer load has replaced.

**Non-Goals:**
- Running the rules tests in CI.
- Changing what the rules allow.
- Firebase App Check.
- The same late-load guard for the Medals list.

## Decisions

### Rules files and deployment
`firestore.rules` and `storage.rules` sit at the repo root, the names and place `firebase init`
uses, and `firebase.json` points at them in `firestore` and `storage` sections. Their content is
what the console holds. They are deployed with
`firebase deploy --only firestore:rules,storage`, so a Hosting deploy is never needed to change
them. A plain `firebase deploy` deploys them too, which is right once the repo is the source of
truth.

### `rules-tests/`
A folder of its own with a `package.json`, so the iOS project gains no root-level Node files.
Its dev dependencies are pinned: `firebase-tools`, `@firebase/rules-unit-testing` and the
`firebase` SDK it needs. Tests use Node's built-in runner (`node --test`), so there is no test
framework to install.

`npm test` runs `firebase emulators:exec --only firestore,storage --project demo-medal-wall
"node --test --test-concurrency=1"`. The test files run one at a time because they share the
emulators: each loads its rules into the Firestore emulator, `firestore.test.js` clears
Firestore after every test, and `storage.test.js` seeds the races its rules read there, so two
files at once replace each other's rules and wipe each other's data. A `demo-` project id
keeps the emulators offline: no login, and nothing can reach the real project. The CLI finds
`firebase.json` by walking up from `rules-tests/`, so it loads the same rules files the deploy
uses. `npm run deploy` runs the deploy command above with the same pinned CLI, after a
one-time `npx firebase login`.

The emulators need JDK 21 or newer: firebase-tools refuses an older Java.

### What the tests check
One test file per rules file, each test acting as the owner, another user, or no one, with data
seeded with the rules switched off:
- every read and write the app makes, shaped as the app makes it, including the batches: an
  edition create or delete with its count change, and a race delete that takes its editions
- the refusals: other users' profiles, medals and races; an edition added or deleted without
  its count change, or a count change of more than one; a changed `id`, `userID` or
  `createdBy`; a distance with a bad unit, value or decimals; a signed-out request
- Storage: owner-only user files, race files for the race's creator or while the race doesn't
  exist, and JPEG-only uploads

### Newest load wins
`RacesViewModel` numbers each load, as `SearchViewModel` does. After its fetch, a load that is no
longer the newest returns without touching `races`, `hasLoaded` or `error`, and only the newest
load ends `isLoading`. Loads are never cancelled, so this holds whichever finishes first.

## Risks / Trade-offs

- [The console and the repo can differ until the first CLI deploy] → before deploying, compare
  the files with what the console shows; after it, change rules only in the repo.
- [The emulators are not production] → limits on document reads in a large batch are not
  fully modelled, so the in-app checks after a deploy still matter.
- [The tests need Java on the machine] → only to run them; building the app does not.
