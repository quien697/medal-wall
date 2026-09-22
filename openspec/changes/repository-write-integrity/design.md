## Context

The three repositories are thin and stateless, which is why the problems in `proposal.md`
are all in the same few lines. Three facts constrain the fix:

- **`setData(from:)` is not the async one.** In `DocumentReference+WriteEncodable.swift` the
  Codable overloads are synchronous, `throws` only from `encoder.encode(value)`, and forward
  to `setData(_:completion:)` with the completion this code leaves `nil`. The SDK's own
  comment on that parameter — "will not be called while the client is offline" — is the whole
  behaviour in one line. There is no `async` Codable overload; the async `setData` takes
  `[String: Any]`, so awaiting means encoding first and passing the dictionary.
- **The app target defaults to `@MainActor`** (`SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor`,
  Swift 6). A repository is therefore main-actor isolated unless it says otherwise, and a
  default argument expression cannot construct one, because default expressions are evaluated
  in a nonisolated context. `PlacePickerViewModel` already hit this and documents it.
- **There is a precedent to copy, not invent.** `PlaceSearchService` is declared in
  `MapKitPlaceSearchService.swift` alongside its implementation, injected as
  `(any PlaceSearchService)? = nil` and resolved with `??` inside `init`, and faked by
  `MedalWallTests/Support/StubPlaceSearchService.swift` — a scriptable stub with outcome
  enums and recorded calls. The repository seam should look like that, so the codebase has
  one injection idiom rather than two.

## Goals / Non-Goals

**Goals:**

- A save reports success only when the Firestore backend accepted it.
- An edition and its count change cannot diverge, and a race delete cannot half-apply.
- `editionCount` is owned by edition writes alone and can never display as negative.
- The three repositories are substitutable, so the fixes above can be written test-first.

**Non-Goals:**

- Changing what is stored. No field, collection, or document shape moves, so other platform
  clients see nothing.
- The remaining findings from the review: merge-vs-replace on update, server timestamps,
  surviving one undecodable document in a list fetch, orphaned Storage files on delete.
  Each is its own change.
- Injecting `StorageService`. It stays constructed inline; tests cover photo-less paths,
  where no upload is attempted.
- Moving `RaceEntryPicker`'s repository behind a ViewModel. It gets the protocol like every
  other call site; the layering violation is left where it is.
- Offline queueing, retry, or a "saved, will sync" state. Out of scope by decision 2.

## Decisions

### 1. Protocol per repository, declared beside its implementation

`MedalRepository`, `RaceRepository`, and `UserRepository` are declared in the existing
`*FirestoreRepository.swift` files, mirroring how `PlaceSearchService` sits in
`MapKitPlaceSearchService.swift`. Each carries the doc comments describing the contract,
including which `AppError` a method throws.

Keeping them in the existing files also avoids adding app-target files, each of which has to
be registered in the test target's curated `membershipExceptions` in `project.pbxproj` or the
test build fails in ways that do not name the real cause.

*Alternative considered:* a `Repositories/Protocols/` folder. Clearer at a glance, but it
splits a two-page contract across two files, breaks with the existing service pattern, and
buys three pbxproj edits.

### 2. Injection as `(any XRepository)? = nil`, resolved in `init`

```swift
init(repository: (any MedalRepository)? = nil) {
  self.repository = repository ?? MedalFirestoreRepository()
}
```

Not `= MedalFirestoreRepository()` as a default argument: under `SWIFT_DEFAULT_ACTOR_ISOLATION
= MainActor` that expression is evaluated nonisolated and will not compile. This is the same
workaround `PlacePickerViewModel` documents, and the comment there should be echoed briefly so
the next reader does not "simplify" it back.

The ten call sites keep working unchanged, because every one of them constructs its ViewModel
without arguments.

### 3. Writes go through the async `setData`, and multi-document writes through `WriteBatch`

Single-document writes encode and await:

```swift
try await ref.setData(Firestore.Encoder().encode(model))
```

Multi-document writes use `WriteBatch`, whose Codable overload
(`setData(from:forDocument:)`) is synchronous and whose `commit()` is `async throws`. So a
batch gives atomicity and acknowledgement in one step — an edition and its counter, or a race
and its editions, commit or fail together and the error surfaces.

*Alternative considered:* a Firestore transaction. Transactions are for read-then-write
decisions; nothing here reads before writing, and `FieldValue.increment` already merges
concurrent increments server-side.

### 4. `editionCount` is written only by edition operations

`createEdition` and `deleteEdition` batch their `FieldValue.increment(±1)` with the edition
write, and the `try?` around the counter disappears — a failed count change now fails the
whole operation, which is the point.

`updateRace` stops sending `editionCount`. A client editing a name holds whatever count it
read when the screen opened; writing it back overwrites an increment another client made in
between, and races are globally readable, so that collision is ordinary. Since `Race` is
`Codable` and encoded whole, this means `updateRace` writes explicit fields rather than the
encoded struct, or encodes and removes the key before writing — decided at implementation
time, whichever reads better next to the other repositories. `createRace` keeps writing the
field, because creating a race does establish its count: zero.

`deleteRace` batches every edition delete plus the race delete into one commit, with no
counter updates at all — decrementing a document that the same batch deletes is work for
nothing. A batch holds 500 operations; a race with 499 editions is not reachable in this
product (an edition is a year), but the code should still commit in chunks above the limit,
editions first and the race last, so an interrupted delete leaves a shrunken race rather than
editions orphaned under a deleted parent.

### 5. Clamping happens where the count is read, not where it is stored

`Race.editionCount` stays a plain `Int` matching what Firestore holds; the clamp
(`max(0, editionCount)`) is applied when the value is handed to the UI. A repository that
silently rewrote a bad value would hide the corruption it was meant to guard against, and
`CLAUDE.md` puts derived values in the ViewModel rather than the view.

### 6. Fakes are scriptable stubs in `MedalWallTests/Support/`

One per protocol — `StubMedalRepository`, `StubRaceRepository`, `StubUserRepository` — built
like `StubPlaceSearchService`: in-memory storage, an outcome that can be scripted to throw a
given `AppError`, and recorded calls so a test can assert that `updateRace` was sent without
a count, or that a failed edition write left no edition behind. `@MainActor`, matching both
the stub precedent and the app target's default isolation.

## Risks / Trade-offs

- **A save made offline now hangs instead of appearing to work.** → Accepted deliberately
  (see the `persistence-integrity` spec): the alternative is reporting success for writes the
  server may still reject. The spinner is already wired, and offline handling can be designed
  properly in its own change rather than emerging from an SDK default.
- **Existing races may already carry a drifted count**, and nothing here repairs one; the
  clamp only stops a negative number reaching the screen. → A recount is a data-migration
  decision, not a code fix, and the counter can only drift once the `try?` and the stale
  overwrite are gone. Worth revisiting after this ships with real data in hand.
- **Ten `init`s change signature at once.** → Each gains one optional parameter with a
  `nil` default, so no call site changes and the compiler catches anything missed.
- **The batch chunking path above 500 editions will never run in practice**, so it will never
  be exercised by real use. → It is covered by a unit test against the stub rather than left
  as untested defensive code.
- **Tests bind the ViewModels to today's error mapping** (`.raceSaveFailed` and friends). →
  That mapping is already the documented contract in `AppError`; a test failing when it
  changes is the point.
