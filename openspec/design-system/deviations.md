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
| `component.MedalImage.earnedBar` | not drawn: a medal image carries no gilt | gilt bar 3 pt (2 pt at `.thumb`) along the square's bottom edge on a medal with a recorded time | The list and the details already state "No time recorded", so the bar repeats text beside it; most medals have a time, so it marks the default rather than the exception; and gold under a gold medal competes with the photo | unreported | 2026-11-03 | MW-38 |
| `component.MedalImage` | drawn by `PhotoImage` like every other photo: the framed photo fills the square with no edge and no `elevation.cutout`; without one, the shared photo placeholder labelled with the face | a background-removed cutout, whole inside the square, casting `elevation.cutout`, on porcelain with an ash hairline | Removing the background is left to a later change. Until then a medal is a photo like any other, so it uses the one photo component rather than a medal-only copy for a fill no photo shows and a hairline; a shadow from an opaque photo would also shadow the whole square, which the design system keeps flat | unreported | 2026-11-12 | MW-38 |
| `component.MedalImage.faceButton` | a FRONT / BACK label (an ink chip) names the face in view on every medal; tapping anywhere on the medal flips it, to an empty face's placeholder too, and the label has no action of its own | a FRONT / BACK button in the top-right corner names the face in view and flips it, shown only when a back exists | The whole medal is the target, so turning it over needs no aim at a small corner control; the corner only names the face, so it is a label, drawn as a chip because chips name things. An empty face in view invites adding its photo. The design system keeps the medal untappable because its square carries gilt, and iOS draws no gilt bar (`component.MedalImage.earnedBar`); adopting the bar would reopen this | unreported | 2026-11-13 | MW-38 |
| iOS mock v4.8.0 · Search medal row | date, name, place, distance; no finish time | name, date, distance · finish time; no place | The place is how a match by place explains itself (`search` spec, "A medal found by its place"); the row changes only its image | unreported | 2026-11-03 | MW-38 |

`color.navy950` (MW-29, since 2026-08-26) was resolved in v4.5.3, which
named the same fixed ink as `color.obsidian` — the code was renamed `Navy950` → `Obsidian` to
match.

Skeleton bone sizes (MW-14, since 2026-10-21) were resolved in v4.6.0, which states the same
bar heights, `radius.tag` corners and capsule chip as `BoneSize`.
