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
| `color.navy950` | `Navy950` `#0F1B2D`, no dark slot | absent | Fixed ink for content sitting on `color.champagne`. Champagne has no dark slot, so anything on it needs a counterpart that does not invert out from under its background. | unreported | 2026-08-26 | MW-29 |

## Notes

**`color.navy950` may be a design system gap rather than an iOS customization.** Its reason
holds on every platform: `champagne` is a design system token with no dark slot, so Android and
web will need the same fixed ink. Worth settling when it is raised with design — if it is a gap,
the design system should name the token and this entry is deleted rather than kept.
