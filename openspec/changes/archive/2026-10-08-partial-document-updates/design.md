## Context

`RaceFirestoreRepository.updateRace` already writes with `updateData`: it encodes the race,
drops `editionCount`, and adds `FieldValue.delete()` for each field in `raceUpdateFields` that
the encoding left out. `RaceFirestoreRepositoryTests` covers the result through the static
`updateFields(for:)`, which is pure Swift and needs no backend. The other three updates still
call `setData` with the encoded model, which replaces the document.

`Firestore.Encoder` omits a `nil` optional rather than writing `null` (synthesized `Codable`
uses `encodeIfPresent`). That is why a field update needs explicit deletes: without them a
cleared value would survive.

## Goals / Non-Goals

**Goals:**

- A user, medal or edition update leaves fields it does not declare untouched.
- Clearing an optional value still removes it from the stored document.
- A model field that nobody added to the update list is caught by a test, not in production.

**Non-Goals:**

- Partial writes inside arrays or maps (see proposal). An unknown key nested in `eventPhotos`,
  `distances`, `place` or `distance` is still lost.
- Writing only the fields a save changed (finding #11). Known fields are still written from the
  copy the client holds.
- Server timestamps for `updatedAt`.

## Decisions

### 1. `updateData` with a declared field list, copying `updateRace`

Each repository gets a static `<model>UpdateFields` list and a static
`updateFields(for:) throws -> [String: Any]`: encode the model, then add `FieldValue.delete()`
for every listed field absent from the encoding. The update calls
`updateData(Self.updateFields(for: updated))`.

Alternative: `setData(_:merge: true)`. Rejected: it needs the same explicit deletes, and it
recreates a document that was deleted elsewhere, which `updateRace` deliberately refuses.

Alternative: one generic helper shared by the four repositories. Rejected for now: each
`updateFields` is three lines, and the race one has its own exclusion (`editionCount`).
Three similar functions read more plainly than a generic over `Encodable`.

### 2. The guard test uses a fully populated model

The existing race guard encodes a race fixture and checks every key is in the list. A new
optional field left `nil` in the fixture would not encode, so the guard would miss it. The new
user, medal and edition guards build a model with every optional set, so any new stored field
shows up as an uncovered key. The race guard is not changed; that is outside this change.

### 3. `User.email` and identity fields stay in the list

`uid`, `id`, `userID`, `raceId`, `createdBy` and `createdAt` never change after creation, but
writing their current value is harmless and keeps the list equal to the model, so the guard
test stays a simple set comparison.

## Risks / Trade-offs

- [A save to a deleted document now throws] → it surfaces through the existing save-error
  sheet in each ViewModel, the same path as any rejected write. `updateUser` only runs once the
  profile exists, so normal profile edits are unaffected.
- [The field list drifts from the model] → the guard test in Decision 2.
- [The behaviour against real Firestore is not unit tested] → the tests cover the field
  dictionary, which is everything decided in Swift; `updateData` itself is the SDK's contract.
