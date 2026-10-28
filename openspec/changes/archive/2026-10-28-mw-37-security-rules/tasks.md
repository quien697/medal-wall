## 1. Race Detail shows its menu to the creator only

- [x] 1.1 Write failing tests in `RaceDetailViewModelTests` for `canManageRace(userID:)`: true
      for the race's `createdBy`, false for another uid, false for `nil` (no signed-in user)
- [x] 1.2 Add `canManageRace(userID:)` to `RaceDetailViewModel` to pass them (design.md, The
      creator check lives in `RaceDetailViewModel`)
- [x] 1.3 `RaceDetailView`: read `UserManager` from the environment and include the ⋯
      `ToolbarItem` only when `canManageRace(userID: userManager.currentUserID)` passes; inject
      `UserManager()` into its preview

## 2. Races list drops swipe-to-delete

- [x] 2.1 Remove the Races list's delete tests from `RacesViewModelRepositoryTests`: the failed
      and successful delete, the logo tests and their helper, offline refused, and the two
      `canDeleteRaces` tests; drop the `networkMonitor:` and `storageService:` arguments the
      remaining tests pass
- [x] 2.2 `RacesViewModel`: remove `deleteRace(_:)`, `canDeleteRaces`, and the `storageService`
      and `networkMonitor` dependencies
- [x] 2.3 `RaceList`: remove `.swipeActions`, `canDelete` and `onDelete`, and update its
      previews
- [x] 2.4 `RacesView`: remove `selectedRace`, `isPresentingDeleteConfirm` and the delete
      confirmation alert, and the arguments it passed `RaceList`

## 3. Verify

- [x] 3.1 Build, and run the full test suite
- [x] 3.2 `openspec validate mw-37-security-rules --strict`
- [x] 3.3 In the simulator: a race you created shows the ⋯ menu; a race created by another uid
      shows none, its editions still listed; no race in the Races list swipes to delete

## 4. Archive

- [x] 4.1 Archive the change, then reword the `races` spec's Purpose, which still says a
      signed-in user has full CRUD over races and editions
