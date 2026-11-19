# Design System Deviations

Deliberate differences between the iOS implementation and the design system (the Design System
page of the Claude design canvas; see `CLAUDE.md`).

**While an entry stands, the iOS value wins.** `design-system-sync` does not report it as a
problem and never writes over it. Do not "fix" a token listed here — read the Why column first.

`Status` is `unreported` (design has not been told; the check asks about it every run) or
`reported` (design knows and it is waiting on a release; the check lists it with its age and
does not re-litigate). An entry still `reported` two design system releases after it was
raised is flagged as stalled.

`design-system-sync` deletes an entry once a release adopts the iOS value, leaving no note here;
git history keeps it. When a release names the token with a *different* value, the check reports
it as superseded and asks for a decision rather than choosing.

| Token | Code | Design system | Why | Status | Since | Ticket |
|---|---|---|---|---|---|---|
| `component.MedalImage.saved` | the framed square at the photo's own pixels, a JPEG under 10 MB | saved as an 840 × 840 JPEG | A stored photo can be made smaller later but never sharper, so a face keeps the pixels the user framed, for large web screens, share images and later effects such as background removal. Storage refuses any upload of 10 MB or more, and the app says so when the framing is confirmed | unreported | 2026-11-19 | MW-25 |
