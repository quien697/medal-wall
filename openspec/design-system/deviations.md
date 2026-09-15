# Design System Deviations

Deliberate differences between the iOS implementation and the Design System document.

**While an entry stands, the iOS value wins.** The check does not report it as a problem and
`apply` does not overwrite it. Do not "fix" a token listed here — read the Why column first.

`Status` is `unreported` (design has not been told; the check asks about it every run) or
`reported` (design knows and it is waiting on a release; the check lists it with its age and
does not re-litigate). An entry still `reported` two design system releases after it was
raised is flagged as stalled.

An entry is deleted when a release adopts the iOS value. When a release names the token with a
*different* value, the check reports it as superseded and asks for a decision rather than
choosing.

| Token | Code | Design system | Why | Status | Since | Ticket |
|---|---|---|---|---|---|---|

No open deviations. `color.navy950` (MW-29, since 2026-08-26) was resolved in v4.5.3, which
named the same fixed ink as `color.obsidian` — the code was renamed `Navy950` → `Obsidian` to
match.
