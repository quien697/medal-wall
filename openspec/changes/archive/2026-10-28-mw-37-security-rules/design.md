## Context

Races are a shared collection: every signed-in user reads every race. Each `Race` and
`RaceEdition` already stores `createdBy`, the uid of the user who created it, but nothing reads
it. Two places in the app edit or delete a race:

- Race Detail's ⋯ menu (`RaceDetailView`): Edit Race opens `EditRaceView`, from which editions
  are added, edited and deleted; Delete Race deletes the race. Race Detail is reached from the
  Races list and from Search.
- The Races list's swipe-to-delete (`RaceList` → `RacesView` → `RacesViewModel.deleteRace`).

The Firebase rules for 1.2.0 (written in the console, listed in MW-37) refuse a race update or
delete, and any edition write, from anyone but the race's `createdBy`. Medals are not affected:
a medal holds no reference to a race.

## Goals / Non-Goals

**Goals:**
- No user is offered an action on a race that the rules refuse.
- One place to delete a race: Race Detail.

**Non-Goals:**
- Letting other users suggest or make corrections to a race; that waits for race-catalog.
- Marking a race as someone else's, or showing who created it.
- Changing who may add a race, or the rules themselves.
- The Races list's handling of a load that finishes after a newer one; unchanged here.

## Decisions

### The creator check lives in `RaceDetailViewModel`
`RaceDetailViewModel.canManageRace(userID: String?) -> Bool` returns whether `userID` equals
`race.createdBy`. With no signed-in user, `nil` never equals a stored uid, so the check fails.
`RaceDetailView` reads `userManager.currentUserID` from the environment and passes it in, the
way `SearchView` and `MedalsView` pass it to their loads.

A function taking the uid, rather than a uid stored on the view model: the view model is
built in the view's `init`, before the environment is readable, and `UserManager` is the one
source of truth for who is signed in.

`race.createdBy` is set once, when the race is created, and race updates keep it unchanged, so
reloading the race after an edit cannot change the answer.

### Hide the menu, don't disable it
The ⋯ menu holds only Edit Race and Delete Race, so for anyone but the creator the whole
`ToolbarItem` is left out. A disabled menu, or one that opens empty, would offer something that
does nothing.

### Remove swipe-to-delete for everyone
Per-row swipe — some races swipeable, others not — reads as broken, so `RaceList` loses its
swipe action outright. Everything that existed only for it goes too: `RaceList`'s `canDelete`
and `onDelete`, `RacesView`'s selected race and delete confirmation, and in `RacesViewModel`
`deleteRace(_:)`, `canDeleteRaces`, and the `storageService` and `networkMonitor` dependencies
nothing else uses. Their tests go with them. Race Detail's delete keeps its own tests: logos
deleted after the race, logos kept when the delete fails, offline refused.

### Editions need no check of their own
Editions are added, edited and deleted only inside Edit Race, and Edit Race opens only from the
⋯ menu, so hiding the menu covers them. Search opens Race Detail, the same screen.

## Risks / Trade-offs

- [A race's creator is only ever one user] → a mistake in someone else's race can't be fixed by
  anyone else. A runner can still type their medal by hand, or add the race themselves. Revisit
  when race-catalog is complete.
- [Races imported by race-catalog carry whatever `createdBy` it writes] → if that is not a
  user's uid, no one sees the menu on those races, which matches the rules.
- [Previews] → `UserManager` signs no one in for a preview, so `RaceDetailView`'s preview shows
  the race without its menu. The creator's view is covered by the view model tests.

## Migration Plan

Ships with 1.2.0. Publishing the rules before or after the app update is safe either way: the
rules refuse only what this change stops offering.
