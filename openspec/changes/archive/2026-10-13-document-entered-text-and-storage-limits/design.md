## Context

The behavior is already implemented and tested; this change only records it. Reviews of MW-32
found medal and race fields saved with stray whitespace, a pasted line break passing
validation, and photos left in Storage when an upload stored a file but its link could not be
fetched. Edit Profile already trimmed its names and bio. The fixes made the three edit sheets
agree, and capped the remaining Storage calls at the 30 seconds uploads already had.

## Goals / Non-Goals

**Goals:**
- State the trimming rules once, in `edit-sheets`, so every client of the shared Firestore
  data can follow them.
- Extend the 30-second promise from uploads to every Storage call a save makes.

**Non-Goals:**
- Changing text inside a value, such as a line break in the middle of a name.
- Case-insensitive tag matching, or cleaning tags and places already stored.
- Guaranteeing that an orphaned photo is always deleted; see Risks.

## Decisions

- **Trim whitespace and line breaks, at the ends only.** All three sheets use
  `.whitespacesAndNewlines`, the set Edit Profile and the note already used. Validation trims
  the same way, so a value Save accepts is never blank once saved.
- **One requirement in `edit-sheets`, not one per record.** The rule is the same on every form
  sheet, and `edit-sheets` already owns how those sheets save.
- **Cap every Storage operation at 30 seconds** (`maxOperationRetryTime`, beside the existing
  `maxUploadRetryTime`). Storage's default is 2 minutes per call, so a save failing after its
  upload could keep its spinner for several minutes. Alternative considered: run the clean-up
  delete without waiting for it. Rejected for now, because every other clean-up path waits and
  the cap already bounds the wait.

## Risks / Trade-offs

- [The clean-up delete after a failed link fetch usually meets the same lost connection, so the
  photo stays in Storage] → Accepted. The medals, races and profile specs already allow a photo
  that fails to delete to stay. A full fix needs a retry queue or a server-side sweep for
  unreferenced files.
- [A save that fails after several uploads still waits up to 30 seconds per clean-up delete] →
  Accepted. Running those deletes concurrently is a separate improvement.
