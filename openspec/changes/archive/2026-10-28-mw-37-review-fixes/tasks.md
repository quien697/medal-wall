## 1. Races list keeps the newest load

- [x] 1.1 Write failing tests in `RacesViewModelRepositoryTests` with `FetchHold`: an older
      load that lands after a newer one leaves the newer races; an older load that fails after
      a newer one succeeded sets no error; an older load that finishes first leaves the list
      unchanged and still loading until the newer one finishes
- [x] 1.2 Number each load in `RacesViewModel.loadRaces` and keep only the newest (design.md,
      Newest load wins)

## 2. Rules in the repo

- [x] 2.1 Add `firestore.rules` and `storage.rules` with the rules published in the console
- [x] 2.2 Add `firestore`, `storage` and `emulators` sections to `firebase.json`; ignore
      `rules-tests/node_modules/` and the emulators' debug logs
- [x] 2.3 Create `rules-tests/` with a pinned `package.json` (`test`, `deploy`) and install it
- [x] 2.4 Write the Firestore rules tests (design.md, What the tests check)
- [x] 2.5 Write the Storage rules tests
- [x] 2.6 Run `npm test` in `rules-tests/` (needs JDK 21) and fix whatever it finds
- [x] 2.7 Add the rules test and deploy commands to `CLAUDE.md`; make the archived MW-37
      proposal and design say the rules live in the repo

## 3. Verify

- [x] 3.1 Run the full iOS test suite
- [x] 3.2 `openspec validate mw-37-review-fixes --strict`
- [x] 3.3 Make the console's rules match `firestore.rules` and `storage.rules`, and check the app
      against them (the user)
