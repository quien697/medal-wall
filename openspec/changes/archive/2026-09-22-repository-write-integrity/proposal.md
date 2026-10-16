## Why

The three Firestore repositories report success for writes the server never accepted. Every
create and update calls `setData(from:)`, which in the Firebase Swift SDK is a synchronous
method that throws only when the model cannot be encoded; the server's answer arrives on a
`completion` closure the code does not pass. A write rejected by a security rule therefore
reaches no one: the ViewModel sees no error, the local cache shows the change, and the change
then vanishes on the next fetch. The functions are declared `async throws` and await nothing.

`Race.editionCount` has the matching problem and one of its own. Its updates are sent with
`try?`, so a failed increment is silently dropped and the count is wrong from then on; the
edition write and the count update are two separate round trips that can diverge; and
`updateRace` rewrites the whole race document including the client's own copy of the count,
so a count another client has since incremented is overwritten with a stale one. Races are a
shared, globally readable collection, so that is a realistic collision, not a theoretical one.
Nothing clamps the value on the way out either, and `RaceRow` will happily render
`-1 editions`.

None of this can be fixed test-first, which is how this project fixes bugs. Every ViewModel
constructs its repository inline (`private let repository = MedalFirestoreRepository()`), and
there is no protocol to substitute a fake for, so neither the repositories nor the ten call
sites that use them have a test seam at all.

## What Changes

- Introduce one protocol per repository — `MedalRepository`, `RaceRepository`,
  `UserRepository` — implemented by the existing `*FirestoreRepository` classes. ViewModels
  and `UserManager` take the protocol through `init` with the Firestore implementation as the
  default argument, so the existing call sites keep compiling while tests can pass a fake.
- Add an in-memory fake per protocol to the test target, and the first unit tests covering
  repository-facing ViewModel behaviour.
- Await every write. Encode with `Firestore.Encoder()` and call the `async` `setData`, so a
  write resolves only once the server has accepted it and a rejection is thrown. A save made
  offline now stays pending until the device reconnects, which is what the ViewModels' own
  spinner-then-error-sheet flow already assumes.
- Write each edition and its count change in a single `WriteBatch`, so the two cannot diverge.
  This is a batch of one logical operation inside the repository, distinct from the
  `EditRaceViewModel` save loops that `CLAUDE.md` deliberately keeps un-batched.
- Stop `updateRace` from writing `editionCount` at all. The count is server-maintained; a
  client that merely edited a name has no business asserting a value for it.
- Clamp `editionCount` to zero or more where it is read, so a corrupt or negative stored value
  cannot reach the UI — per the existing "guard numeric values" rule in `CLAUDE.md`.
- Delete a race and all of its editions in one batched commit, replacing the current loop of
  `2N + 1` sequential round trips that decrement a counter on a document about to be deleted
  and that can stop halfway, leaving a half-deleted race behind.

## Capabilities

### New Capabilities
- `persistence-integrity`: what the app guarantees about a write — that a save reports
  success only when the server accepted it, that a multi-document change commits atomically,
  and that the persistence layer is substitutable so these guarantees can be tested.

### Modified Capabilities
- `races`: adds the edition count's correctness contract (server-maintained, never asserted
  by a client edit, never displayed below zero), and tightens the existing cascade-delete
  scenario from "deletes all editions before deleting the race" to a single atomic commit.

## Impact

- `MedalWall/Repositories/` — all three repository files; new protocol declarations.
- ViewModel and manager `init`s at the ten construction sites, including
  `RaceEntryPicker.swift:15`, where a View owns a repository directly. This change gives it
  an injected protocol; moving that call behind a ViewModel is out of scope.
- `RaceRow` / `RaceList` — the clamped count.
- `MedalWallTests/` — new fakes and tests. New files must be added to the test target's
  `membershipExceptions` in `project.pbxproj` or the test build fails in confusing ways.
- No Firestore schema change: same collections, same fields, same document shapes. Other
  platform clients are unaffected.
- Out of scope, and left for separate changes: merge-versus-replace on update (an iOS write
  currently drops fields written by a future web or Android client), server timestamps
  instead of the device clock, tolerating one undecodable document in a list fetch, and the
  orphaned Storage files left behind when a race or medal is deleted.
