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
| skeleton bone sizes | `BoneSize` in `SkeletonViewModifier.swift`: bars overline 10, caption 10, body 12, callout 14, headline 16, Numeric.medium 18, title2 24, Numeric.large 30, tag 20, chip 20 (capsule); corners `radius.tag` (6) | not named; iOS mockup v4.5.5 draws bars of these heights with 5–6 corners | Every bar of one text style must match across screens, and the token list gives no size, so the values come from the mockup | unreported | 2026-10-21 | MW-14 |

`color.navy950` (MW-29, since 2026-08-26) was resolved in v4.5.3, which
named the same fixed ink as `color.obsidian` — the code was renamed `Navy950` → `Obsidian` to
match.
