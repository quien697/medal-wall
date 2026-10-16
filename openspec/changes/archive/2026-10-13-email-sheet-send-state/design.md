## Context

Follows `2026-10-13-email-link-edge-cases-and-gregorian-years`; review R8 of MW-32.

## Decisions

**The spinner follows the same closing counter as the rest of the sheet's state.**
`resetEmailFlow` clears `isSendingEmail`, and a send clears it on finishing only if its sheet
has not closed since it started, so an old send cannot stop the spinner of a send started from
the reopened sheet.

**The field takes the sent address.** On a successful send the field is set to the trimmed
address, so the confirmation, which reads the field, names what was actually sent.
