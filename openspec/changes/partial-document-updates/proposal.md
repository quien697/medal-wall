## Why

`updateUser`, `updateMedal` and `updateEdition` replace the whole Firestore document with
`setData`, so any field this iOS build does not know about is erased on the next save. Web,
admin and Android clients are planned against the same documents, and a field one of them adds
would be silently wiped by every iOS profile, medal or edition edit. No other client exists
yet, so nothing is lost today; fixing it before they ship is what keeps the documents shareable.
`updateRace` already avoids this, and `repository-write-integrity` deferred the other three to
their own change.

## What Changes

- `updateUser`, `updateMedal` and `updateEdition` send a field update (`updateData`) instead of
  a whole-document replace, the way `updateRace` does. A field the model does not declare is
  left untouched.
- Each update carries an explicit delete for every optional field the model no longer holds,
  so clearing a bio, a finish time, a note or a photo still removes the stored value.
- Each repository declares the list of fields its update owns, with a test that fails when the
  model gains a field missing from the list.
- **BREAKING (behaviour)**: an update to a document that no longer exists now fails instead of
  recreating it, matching `updateRace` — an edit should not resurrect a medal or edition that
  was deleted elsewhere.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `persistence-integrity`: adds a requirement that an update writes only the fields the app
  owns and leaves every other stored field as it was.

## Impact

- `MedalWall/Repositories/UserFirestoreRepository.swift`, `MedalFirestoreRepository.swift`,
  `RaceFirestoreRepository.swift` (edition update only).
- New repository tests for user and medal update fields; edition cases added to
  `RaceFirestoreRepositoryTests`. New test files must be added to the test target's
  `membershipExceptions` in `project.pbxproj`.
- No Firestore schema change: same collections, fields and document shapes.
- Out of scope:
  - Arrays (`Medal.eventPhotos`, `Medal.tags`, `RaceEdition.distances`) and maps
    (`Medal.place`, `Medal.distance`) are still written whole, so an unknown key nested inside
    one is still lost. Fixing that changes the document shape.
  - Stale values for fields the app does know about (review finding #11): a profile save
    writes back the milestone counts it read, which can lower a count another device raised.
    That needs saves to write only the fields they changed, and is its own change.
