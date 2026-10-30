## Context

The rules check the edition count from each edition write: an edition create needs the count
to rise by one and stay at or below 200, an edition delete needs the count to drop by one or
the race to be deleted in the same commit. A delete of a document that does not exist still
runs the rule, and nothing kept the count from going below zero. An edition's rules read its
race with `get()`, which fails when the race is gone.

Seven loads number themselves so an older result cannot replace a newer one. Each keeps only
the newest *started* load's result: an older load that succeeds while a newer one runs is
dropped, so if the newer one then fails, nothing loaded is shown.

## Goals / Non-Goals

**Goals:**
- No commit can push `editionCount` below the real number of editions, or below zero.
- Editions under a race that is gone can be deleted by the race's creator.
- A null optional is accepted wherever the app reads null as none.
- One implementation of the load rule, with no fresher result dropped.

**Non-Goals:**
- Refusing a commit that adds several editions with one count change. Each edition's rule sees
  only the count the commit leaves, so it cannot count the editions beside it; refusing it
  needs a field on the race naming the edition being added, a schema change for a gap only the
  race's creator can use, on their own race.
- A city for every place: held for a separate decision.

## Decisions

### Edition delete
```
allow delete: if (signedIn() && !exists(racePath())
                   && (resource == null || resource.data.createdBy == request.auth.uid))
              || (isRaceCreator()
                   && (!existsAfter(racePath())
                       || (resource != null && countChange() == -1)));
```
- **Race already gone:** the edition is left over, so its creator may delete it, and deleting
  one already gone changes nothing. An edition's `createdBy` is the race's creator: the create
  rule requires both to be the requester.
- **Race deleted in the same commit:** unchanged.
- **Count drops by one:** only for an edition that exists, so a second delete of the same
  edition is refused rather than lowering the count again.

`isValidRace` gains `editionCount >= 0`, so no update leaves a negative count.

### Null optionals
`isValidMedal` accepts `result` absent or null, and `isValidPlace` accepts `region` absent,
null or text, through `get(key, null)`, as `isOptionalString` does for races.

### LoadSequence
A struct each view model keeps per kind of load:
- `begin()` numbers a load.
- `shouldApply(_:)` is true when no newer load's result has been applied, and records this
  load as applied. A load may apply in steps (Medal Detail applies the medal, then the record
  marker), so it stays applicable while nothing newer has applied.
- `isNewest(_:)` is true for the newest started load: only it presents an error, ends the
  loading state, or marks a fetch finished.

So an older load that finishes first shows its result while the newer one still runs, and a
newer load that fails leaves the older result on screen with the error. An older load that
lands after a newer one has applied changes nothing, as before.

Cancelling the older load instead does not work here: Firestore's async fetches do not stop
when their task is cancelled, and the loads start from unstructured `Task`s nothing cancels.

Race Detail keeps one sequence for its editions and one for the race; Search one for medals
and one for races, begun together.

### Explicit `@MainActor`
The test module compiles the app's files with Swift 5 and no default actor, so these view
models are nonisolated there, and overlapping-load tests run their state changes off the main
actor. Marking them `@MainActor`, as `SearchViewModel` is, makes the tests run them as the app
does.

## Risks / Trade-offs

- [An older result can show briefly before the newer one] → it is never older than what was on
  screen, and the newer result replaces it when it lands.
- [A commit adding several editions with one count change is still accepted] → only from the
  race's creator; the app adds one edition per commit, and other clients must do the same.
