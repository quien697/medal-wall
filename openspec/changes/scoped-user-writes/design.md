## Context

`UserManager` writes the user document in two places, both through
`UserRepository.updateUser(_:)`, which encodes the whole `User` and sends it with `updateData`
(`partial-document-updates`):

- `updateUser(_:photo:)` saves a profile edit from `EditProfileViewModel.makeUpdatedUser()`, a
  copy of `currentUser` with the form's values applied.
- `refreshAchievementMilestones(medals:)` runs after each medal create or edit. It ratchets
  `currentUser`'s milestones against the live medal counts and writes the user only when a
  tier went up.

`currentUser` is fetched when the session becomes known, at cold launch. Coming back from the
background refetches it only if it failed to load or came from the phone's copy
(`reloadProfileIfNeeded`). So a device can hold milestones that are days older than the
server's, and either write sends them back.

## Goals / Non-Goals

**Goals:**
- A stored milestone is never lowered, whatever the writing device's copy holds.
- A profile save cannot touch milestones; a milestone raise cannot touch profile fields.
- The field-list guard from `partial-document-updates` keeps covering every `User` field.

**Non-Goals:**
- Reloading the profile when the app returns to the foreground.
- Merging concurrent profile edits: the last save still wins for profile fields.
- Server-side enforcement (security rules or functions are not in this repo).

## Decisions

### Two repository writes instead of one

`updateUser(_:)` becomes `updateProfile(_:)` and `raiseMilestones(uid:full:half:)`, each with
its own static field list: `profileUpdateFields` (`firstName`, `lastName`, `photoUrl`, `bio`,
`gender`, `birthday`, `updatedAt`) and `milestoneFields` (`highestFullMilestone`,
`highestHalfMilestone`). `uid`, `email` and `createdAt` go in `neverUpdatedFields`.

- *Alternative: one `updateUser(_:fields:)` taking a field list.* Callers would have to pick
  the right list, and nothing would stop a caller passing milestones with a plain write. Two
  methods make the milestone path the only one that can write milestones, and it is always
  the transaction.

`updateProfile` keeps the current shape: encode, keep only `profileUpdateFields`, add
`FieldValue.delete()` for each one missing, stamp `updatedAt`, `updateData`.

`updatedAt` belongs to the profile save only, meaning "when the profile was last edited". A
milestone raise does not stamp it, so no field is written by both.

### The milestone raise is a transaction taking the higher value

`raiseMilestones` runs `runTransaction`: read the user document, take the stored milestones,
compute `max(stored, proposed)` per track, write the two fields only if either went up, and
return the resulting pair. The merge is a pure static function,
`raisedMilestones(stored:proposed:)`, so it is tested without Firestore. A stored value that is
missing, not an integer, or negative reads as `0`.

- *Alternative: `FieldValue.increment`.* Milestones are tier thresholds, not counters; there is
  no increment that means "at least this".
- *Alternative: refetch the user, then write.* Two devices could still interleave between the
  read and the write. The transaction retries on contention for no extra code.

A transaction fails at once when offline instead of queueing. That suits this write:
`refreshAchievementMilestones` already ignores failure, and the next medal save raises it.

### `UserManager` keeps its local check and takes back the stored values

`refreshAchievementMilestones` still compares the ratcheted value with `currentUser`'s copy and
returns early when neither track went up, so most medal saves cost nothing extra. Skipping is
safe: the copy was read from the server and stored milestones never go down, so the copy is
never above the stored value; a value not above the copy is not above the stored value either.
When it does call `raiseMilestones`, it sets `currentUser`'s two milestones to the returned
pair, which may be higher than what it asked for.

`updateUser(_:photo:)` calls `updateProfile` and otherwise behaves as today.

### Guard test

The existing guard (a fully populated `User`'s encoded keys must be in `userUpdateFields`)
becomes: those keys are covered by `profileUpdateFields ∪ milestoneFields ∪
neverUpdatedFields`, and the three lists do not overlap.

## Risks / Trade-offs

- [A milestone raise now needs a connection] → It was already skipped for a cached profile and
  retried on the next medal save; display uses `max(persisted, live)`, so the badge shows
  correctly in the meantime.
- [One extra read on a save that crosses a tier] → Only those saves; at most a few per user per
  year.
- [A corrupt, very large stored milestone is kept] → Same as today; display already clamps to
  the tier range.
- [Profile fields still last-save-wins between devices] → Accepted by the `profile` spec; out
  of scope here.

## Migration Plan

No data migration: the document and its fields are unchanged. Rollback is reverting the
commit.
