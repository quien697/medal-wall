## 1. Test seam

- [x] 1.1 Declare `MedalRepository`, `RaceRepository`, and `UserRepository` in their existing
      `*FirestoreRepository.swift` files, each method carrying a `///` comment naming the
      `AppError` its callers map it to; conform the three Firestore classes to them.
- [x] 1.2 Add `StubMedalRepository`, `StubRaceRepository`, and `StubUserRepository` to
      `MedalWallTests/Support/`, modelled on `StubPlaceSearchService`: in-memory storage, a
      scriptable outcome that can throw a given `AppError`, and recorded calls.
- [x] 1.3 Inject the protocol at all ten construction sites as
      `init(repository: (any XRepository)? = nil)` resolved with `?? XFirestoreRepository()`,
      with a one-line comment on why it is not a default argument (main-actor isolation).
      Sites: `UserManager`, `ProfileViewModel`, `EditMedalViewModel`, `MedalDetailViewModel`,
      `MedalsViewModel`, `EditRaceViewModel`, `EditRaceEditionViewModel`, `RacesViewModel`,
      `RaceDetailViewModel`, `RaceEntryPicker`.
- [x] 1.4 Register any new app-target file in the test target's `membershipExceptions` in
      `project.pbxproj`; confirm the test target still builds.
- [x] 1.5 Write the first ViewModel test against a stub — `MedalsViewModel` loading medals —
      proving the seam works with no Firestore connection.

## 2. Acknowledged writes

- [x] 2.1 ~~Failing test: a stub scripted to throw on write makes `EditMedalViewModel.save()`
      set `.medalSaveFailed`~~ — wrong as written: `EditMedalViewModel.save` rethrows and the
      view does the mapping. Covered instead where the mapping really lives: the race,
      edition and medal-delete ViewModels.
- [x] 2.2 Convert every `setData(from:)` in the three repositories to
      `try await ref.setData(Firestore.Encoder().encode(model))`.
      *No unit-testable surface*: whether a write waits for the backend is Firestore's
      behaviour, not ours. Verified by inspection; task 6.2 is the real check.
- [x] 2.3 Repeat 2.1 for the race, edition, and user save paths (`.raceSaveFailed`,
      `.editionSaveFailed`, `.userSaveFailed`), so each ViewModel's mapping is covered.
      **Gap: the user path is untested** — `UserManager.init` attaches a live Firebase auth
      listener, so constructing one in a unit test reaches Firebase.
- [x] 2.4 Check every repository method is now genuinely `async`, and that no call site
      relied on a save returning before the server answered.

## 3. Edition count integrity

- [x] 3.1 ~~Failing test: a failed count change fails the whole edition write~~ — batch
      atomicity is Firestore's guarantee, not our code's, so there is nothing to unit test.
      The observable part — a failed edition write leaves no edition and surfaces the error —
      is covered in `EditRaceEditionViewModelRepositoryTests`.
- [x] 3.2 Batch the edition write and its `FieldValue.increment(±1)` in `createEdition` and
      `deleteEdition`, removing the `try?` around the counter.
- [x] 3.3 Failing test: saving a race edit does not write `editionCount`.
      Tested as a pure function (`RaceFirestoreRepository.updateFields(for:)`) plus an
      end-to-end stub test that a count changed elsewhere survives an edit.
- [x] 3.4 Stop `updateRace` from writing `editionCount`; leave `createRace` establishing zero.
      Uses `updateData` with an explicit `FieldValue.delete()` for cleared optionals —
      `setData(mergeFields:)` throws an Objective-C exception when a masked field is absent
      from the payload, which would have crashed on clearing a race photo.

## 4. Batched race delete

- [x] 4.1 Failing test: when the delete commit fails, the race and all of its editions remain
      and `.raceDeleteFailed` is surfaced. (At the ViewModel seam; the commit's atomicity
      itself is Firestore's.)
- [x] 4.2 Rewrite `deleteRace` to commit every edition delete plus the race delete in one
      batch, with no counter updates.
- [x] 4.3 Failing test: a race with more editions than one batch holds still deletes fully,
      editions before the race.
- [x] 4.4 Chunk the batch at the 500-operation limit, editions first and the race last.

## 5. Clamped count

- [x] 5.1 Failing test: a race whose stored `editionCount` is negative is presented as `0`.
- [x] 5.2 Clamp with `max(0, ...)` in `RacesViewModel` where the row's count is derived, and
      pass the clamped value to `RaceRow`.

## 6. Verify

- [x] 6.1 Run the full test suite on the iPhone 17 Pro simulator; all tests pass.
      519 passing, including the 110 pre-existing ViewModel cases.
- [x] 6.2 Exercise the real app against Firestore: create, edit, and delete a race with
      editions, and create, edit, and delete a medal — confirm counts stay right and errors
      appear when a write is refused. Verified by Quien on a physical device.
      The deliberate-failure checks (refused writes, via temporary security rules) were
      offered and skipped as unnecessary.
- [x] 6.3 Confirm no UI tokens changed, so `design-system-check` is not required for this
      change. No colour, font, radius, spacing or modifier was touched.
- [ ] 6.4 Archive the change (`openspec-archive-change`) so `persistence-integrity` and the
      `races` delta fold into `openspec/specs/`.
