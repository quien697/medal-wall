---
name: design-system-check
description: Compare the Medal Wall Design System document against the iOS token code and report what disagrees. Use when the design system is updated to a new version, when `openspec/design-system/tokens.json` is older than the newest design system file, before finishing a change that touches colours, fonts, radii, spacing, or the action/chip/tag modifiers, or when the user says "check the design system", "did the tokens change", "run the design check", or asks whether the code is up to date with the design system. Pass `apply` to also write the design system's values into the code.
---

Compare the Design System document against the iOS token code, record what the document says,
and report what disagrees.

Read-only by default. `$ARGUMENTS` containing `apply` also writes values into the code, under
the limits in **Applying** below.

## Read, in this order

**1 · The design system.** Glob `~/Code/Personal/Projects/medal-wall/documents/Design System/`
for `Medal Wall Design System v*.html` and take the highest version. Filenames are versioned
and get renamed, so never hardcode one. Its token blocks are `<pre>` elements — find them by
what they contain, not by their position, because the order changes between versions:

| Family | Find the block containing | Yields |
|---|---|---|
| `color` | lines starting `color.paper` | name → light hex, dark hex, role |
| `type` | a Swift `extension Font…` | name → size, weight, tabular |
| `radius` | lines starting `radius.tag` | name → number, or `capsule` |
| `space` | a Swift `extension CGFloat` with `struct Space` | name → number |
| `component` | lines starting `ActionStyle` | enum → case names |

The document also states `type` and `space` for Kotlin and CSS. Read those too — they feed the
internal-consistency report below.

**2 · The previous record.** `openspec/design-system/tokens.json`, if it exists.

**3 · The code.**

| Family | Source |
|---|---|
| `color` | `MedalWall/Assets.xcassets/Colors/*.colorset/Contents.json` |
| `type` | `Font.TypeScale` in `MedalWall/Shared/Extensions/Font+Extensions.swift` |
| `radius`, `space` | `CGFloat.Radius` / `CGFloat.Space` in `CGFloat+Extensions.swift` |
| `component` | `ActionStyle`, `ChipStyle`, `TagStyle` in `MedalWall/Shared/Modifiers/` |

Colour components are `"red"`/`"green"`/`"blue"` strings that are **either** floats (`"0.788"`)
**or** hex (`"0x0F"`) — handle both. Converting 17 colour sets by hand is error-prone; write a
throwaway script in the scratchpad to do the arithmetic if that is easier, but do not add one to
the repo. This check is a skill precisely because the document's format keeps changing.

**4 · The ledger.** `openspec/design-system/deviations.md`. If it is missing or its table will
not parse, say so and stop — do not continue as if there were no deviations, which would report
every declared one as a problem.

## Compare

**Compare what renders, not how the file spells it.** A colour set with no dark appearance shows
its light value in both modes, so it equals a design system token whose light and dark values are
the same. `champagne` is exactly this case and is a match, not a deviation.

Names differ by convention. State which pairings you used:

```
fieldLabel → Field.label      numericL → Numeric.large     label → overline
fieldValue → Field.value      numericM → Numeric.medium
                              numericS → Numeric.small
```

`radius.pill` is `capsule` and has no constant — SwiftUI expresses it natively, so its absence
from `CGFloat.Radius` is correct, not missing. A design system token you cannot pair with
anything is **reported**, never skipped.

Every token gets one verdict:

| Verdict | Condition |
|---|---|
| `match` | equal — not listed individually |
| `drift` | both have it, values differ, no ledger entry — **a problem** |
| `undeclared lead` | in code, not in the design system, no ledger entry — **a problem** |
| `declared deviation` | differs, and a ledger entry stands — the iOS value wins |
| `unimplemented` | in the design system, not in code — informational, never a problem |

`unimplemented` is normal and healthy: the design system is allowed to describe more than the app
has built.

## Ledger entries

While an entry stands the iOS value is correct. Never report it as a problem, never overwrite it.

Then check what the current design system says about each entry's token:

| Outcome | Condition | Report |
|---|---|---|
| `open` | still absent, or still differs the same way | per status, below |
| `resolved` | the design system now states the iOS value | recommend deleting the entry |
| `superseded` | the design system now names it with a **different** value | **ask for a decision** |

`superseded` is the one thing this check never decides. The entry's condition — the iOS value
wins until the design system updates — has been met, and the design system ruled differently. It
may still be wrong, because a deviation often rests on device evidence a document does not have.
Name both values and stop.

For `open` entries the actionable thing is inaction, not the deviation:

- `unreported` — design has not been told. **Ask about it every run.**
- `reported` — design knows; it is waiting on a release. List it with its age; do not
  re-litigate. If it has been `reported` across two or more design system releases, flag it as
  **stalled** — a dropped hand-off is invisible otherwise.

## Report, in this order

1. **Family counts** against the previous `tokens.json` — `color 16 → 16`, `type 13 → 13`. Call
   out by name any family that **shrank**, before anything else. A family you failed to read
   looks exactly like agreement, so this is the one guard against your own worst failure. With no
   previous record, say you are establishing the baseline.
2. **Problems** — `drift` and `undeclared lead`, with both values.
3. **Unreported deviations** — ask whether each has been raised with design.
4. **Reported deviations** — with age; flag stalled ones.
5. **Resolved and superseded entries** — what to delete, what needs a decision.
6. **Unimplemented tokens** — one line.
7. **Design system internal consistency** — its own section. Where the document's Swift, Kotlin
   and CSS blocks state different sizes or weights for the same token, or one omits a token the
   others carry, report it. These are defects **in the design system**, not in the code: no
   platform block has authority over the others, so this never counts as `drift`. As of v4.5,
   `display` is 32 in the Swift and CSS blocks and 28 in the Kotlin block.
8. **A verdict line** — say plainly whether any `drift` or `undeclared lead` was found. Say it
   even when the answer is none; silence is not a result.

## Write `tokens.json`

Write what the design system said to `openspec/design-system/tokens.json`:

```json
{
  "source": { "file": "Medal Wall Design System v4.5.html",
              "version": "4.5", "sha256": "<first 16 hex of the file's sha256>" },
  "color":     { "gilt": { "light": "#C9A227", "dark": "#C7A84A", "role": "earned records only" } },
  "type":      { "display": { "size": 32, "weight": "black", "tabular": false } },
  "radius":    { "tag": 6, "pill": "capsule" },
  "space":     { "inline": 4 },
  "component": { "ActionStyle": ["primary", "secondary", "tertiary", "neutral", "plain", "destructive"] }
}
```

Hash the content, not the version string: a design system version can be revised in place
without its filename changing — v4.5 already was. Tell the user to review the `git diff` of this
file, because it is the design system's changelog. Nothing else records what a version changed;
`documents/` is not under version control and each version replaces the last.

## Applying

Only with `apply` in `$ARGUMENTS`.

**Write** design system values into: the `.colorset` `Contents.json` files, `Color.Pigment`,
`CGFloat.Radius`, `CGFloat.Space`, and the values in `Font.TypeScale`.

**Never write:**

- any token a ledger entry covers, in any status — the iOS value wins
- the colour role structs — `Background`, `Surface`, `Border`, `Text`, `Record`, `TierBadge`,
  `Status`
- the modifier enums
- any doc comment

The role structs and enums are design reasoning written as code. `Record.primary = Pigment.gilt`
encodes *gold is never tappable*; `TierBadge.lockedInner = Pigment.ash` encodes *no gold until it
is earned*. Rewriting them from a token list would keep the values and delete the thinking.

Show the changes and let the user review before anything is committed.

## After

If the design system moved, the follow-through is a change, not just a report: update the ledger,
and if anything user-visible shifted, open an OpenSpec change per `docs/development-workflow.md`.
