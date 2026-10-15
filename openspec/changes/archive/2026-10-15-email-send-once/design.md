## Context

Review R9 of MW-32 (2026-10-15).

## Decisions

**Guard on `isSendingEmail` at the top of `sendEmailLink`.** The method runs on the main actor
with no suspension between the check and setting the flag, so a second call always sees the
first. Closing the sheet already clears the flag, so a reopened sheet can still send while an
abandoned send finishes.
