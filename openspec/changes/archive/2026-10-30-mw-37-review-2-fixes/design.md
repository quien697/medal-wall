## Context

The Firestore and Storage rules are in the repo (`firestore.rules`, `storage.rules`) and tested
against the emulators in `rules-tests/`. They check who may write a race or edition, but only
part of what is written. The app decodes the Races list, Search and an edition list in one piece
(`try snapshot.documents.map { try $0.data(as:) }`), so a single document the decoder cannot
read fails the whole list. Races are created by any signed-in user and read by all of them.

`RaceFirestoreRepository.deleteRace` splits a race's editions into batches of 499, with the race
in the last one. The edition delete rule passes only when the race is deleted in the same batch
or the count drops by one, so every batch before the last is refused.

## Goals / Non-Goals

**Goals:**
- The rules refuse a race or edition the iOS decoders cannot read.
- A race's delete is one commit, and it succeeds when the race is already gone.
- No commit can change an edition and the count together except an edition create or delete.
- Storage accepts race files only where the app writes them.
- A race holds at most 200 editions, enforced in Edit Race and by the rules.

**Non-Goals:**
- Checking every distance of an edition. Rules cannot loop, and only the race's creator writes
  editions. The first distance is still checked: a client with a format bug writes every
  distance the same way, so the first one catches it. Skipping documents the app cannot read
  is MW-35.
- A size cap on uploads (MW-25).
- Validating medals and profiles further: each is read only by its owner.
- Loads that run once each time their screen opens: Edit Race, the race picker and the photo
  loads. Nothing starts a second one while the first runs.
- `UserManager`'s profile load: it is app state rather than a screen's load, and already drops
  a result for an account that has changed.

## Decisions

### The rules check what the decoders require
`isValidRace` checks a race's fields against `Race`: `name` a string that is not blank after
trimming, `place` valid, `editionCount` an int, `createdBy` a string, `createdAt` and
`updatedAt` timestamps, and `photoUrl` and `websiteUrl` absent, null, or strings. Race create
and both race update branches check the whole document after the write with it.
`isValidEdition` gains the same for `RaceEdition`: `year` an int, `startDate`, `endDate`,
`createdAt` and `updatedAt` timestamps, `raceId` and `createdBy` strings, and an optional
`photoUrl`.

The checks require what the decoders already require, so every document the app reads today
passes them. Extra fields are not refused: the decoders ignore them. `createdAt` is checked for
its type only; its value can shift by a microsecond on each save (MW-37).

### A race already gone can be deleted
`allow delete: if resource == null || isUser(resource.data.createdBy)`. Deleting a document
that does not exist changes nothing, so it is allowed to anyone signed in. Before this, the rule
read `createdBy` from a missing document and refused, and Race Detail showed a delete error for
a race another device had already deleted.

### An edition update cannot change the count
The edition update rule adds `countChange() == 0`. A batch that sets an existing edition and
raises the count, such as a retried add whose first commit landed, is refused as a whole.

A count change of one on its own, with no edition written, is still accepted from the race's
creator: the race's rule cannot see the rest of the batch, so nothing on the race's side can
tell a lone count change from one with its edition. Only the creator can send it, and only for
their own race.

### Race files only at the logo paths
`races/{raceId}/{allPaths=**}` becomes four matches: `raceLogo/{file}`, `logo.jpg`,
`editions/{editionId}/editionLogo/{file}` and `editions/{editionId}/logo.jpg`. Each keeps the
same read, write and delete conditions. Uploads under a race id with no document stay open to
anyone signed in, because Add Race uploads the logo before it creates the race. Uploading after
the create would close that, but changes Add Race's save; the size cap (MW-25) bounds what one
upload can store.

### 200 editions per race
`Race.maxEditionCount = 200`. An edition is one year of a race, and the oldest races are around
their 130th edition (Boston, 2025). Any limit up to 499 keeps a race's delete in one commit of
its editions plus the race.

- **Rules:** edition create adds `getAfter(racePath()).data.editionCount <= 200`. The number is
  written in the rules too; a comment next to it names `Race.maxEditionCount`.
- **Edit Race:** `EditRaceViewModel.canAddEdition` counts the editions the section would save:
  the drafts not staged for deletion. Until the editions have loaded, the race's stored count,
  clamped to zero or more, stands in for the ones not shown yet, so Add is not enabled for a
  full race while it loads.
- **`EditRaceEditionSection`** takes `canAddEdition`, disables Add when it is false (the
  disabled look comes from `.actionStyle`), and shows the note as the section's footer, in the
  footer style Settings uses.

### One batch for a race's delete
`deleteRace` deletes every edition and the race in one batch. `deletionChunks`, `batchLimit` and
their tests go.

Repeated lookups of the same document are cached and do not count toward Firestore's limit of
20 lookups per batch. Checked in the emulator: a batch deleting a race with 200 editions passes,
while the emulator does enforce the limit (a write with 11 different lookups is refused).

### Newest load wins on every screen
Every load a screen can start again while one is running numbers each load, as `RacesViewModel`
and `SearchViewModel` do. After its fetch, a load that is no longer the newest returns without
touching what it loads, `hasLoaded` or `error`, and only the newest load ends `isLoading`.
Loads are never cancelled, so they can overlap:

| Load | Starts when |
|---|---|
| `RaceDetailViewModel.loadEditions` | Race Detail opens; Edit Race closes |
| `RaceDetailViewModel.loadRace` | Edit Race closes |
| `MedalsViewModel.loadMedals` | the Medals list appears; Add Medal closes |
| `ProfileViewModel.loadMedals` | the You tab appears |
| `MedalDetailViewModel.reloadMedal` | Edit Medal closes |

`loadRace` and `loadEditions` count separately: each is the newest of its own kind.
`reloadMedal` fetches the medal and the whole collection side by side and still applies
whatever loads, checking after each fetch: once a newer reload has started it applies nothing
more and throws nothing.

The stubs' `fetchEditions`, `fetchRace` and `fetchMedal` answer with what was stored when the
fetch started, as `fetchRaces` and `fetchMedals` do, so a held fetch can land out of date.
`fetchRace` goes through `FetchHold`; `fetchMedal` has a hold of its own, so a test can hold
the medal fetch while the collection fetch beside it goes through.

## Risks / Trade-offs

- [`editionCount` is not the true number of editions] → the limit trusts the count, which only
  the creator can push off, by a lone change of one at a time. A race's delete still fits one
  commit unless the count is short by about 300.
- [The lookup caching is checked only in the emulator] → after the deploy, delete a race with
  several editions on a device.
- [The rules and `Race.maxEditionCount` hold the same number] → each names the other in a
  comment, and the rules tests cover the limit.
