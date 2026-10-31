## Why

Firestore and Storage have no security rules yet, and 1.2.0 cannot ship without them (Jira
MW-37). For this version the rules let any signed-in user add a race, but only the race's
creator edit or delete it, manage its editions, and change its logos. The app still offers Edit
Race and Delete Race to everyone, so every other user would be shown actions the rules refuse,
each ending in a save or delete error.

## What Changes

- **Race Detail** shows its ⋯ menu (Edit Race, Delete Race) only to the race's creator: the
  signed-in user whose uid the race records as `createdBy`. Anyone else sees no menu. Editions
  are added, edited and deleted only from Edit Race, so they follow.
- **BREAKING (UI):** the **Races list** no longer offers swipe-to-delete, to anyone, so every row
  behaves the same; a race is deleted from Race Detail.
- Adding a race is unchanged: every signed-in user can, and becomes its creator.
- The rules themselves live in `firestore.rules` and `storage.rules`, tested in `rules-tests/`.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `races`: Race Management and Race Edition Management give updating and deleting a race, and
  adding, editing and deleting its editions, to the race's creator alone, and say where the app
  offers them. Offline Race Delete Is Refused loses the Races list, which no longer deletes.
- `skeleton-loading`: Skeleton on First Load drops the rule that a reloading Races list offers
  no swipe-to-delete, and its scenario; the list offers none at all now.

## Impact

- **Race Detail:** `RaceDetailViewModel` gains the creator check; `RaceDetailView` reads the
  signed-in uid from `UserManager` and shows the ⋯ menu only when the check passes.
- **Races list:** `RaceList` loses its swipe action and its `canDelete`/`onDelete` parameters;
  `RacesView` loses the delete confirmation; `RacesViewModel` loses `deleteRace`,
  `canDeleteRaces`, and the storage and network dependencies only the delete used. Their delete
  tests go with them; Race Detail's delete tests already cover deleting a race.
- **Tests:** new `RaceDetailViewModel` tests for the creator, another user, and no signed-in
  user.
- No Firestore schema, repository, localization, design-token or dependency changes.
