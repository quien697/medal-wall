## Why

The design system, the iOS token code, and `CLAUDE.md` drift apart silently, and nothing in
the workflow notices. During MW-30 the code legitimately ran ahead of the design system — a
mockup that read well on screen was wrong on a physical device — but there was no way to
record that the design system now owed an update, so the lead became indistinguishable from
a mistake. The reverse happens too: a new design system version lands, replaces the previous
file in place, and nothing says which tokens moved.

Solo, a deviation lives for an hour, because the same person fixes the design system. In a
team it lives for as long as the design hand-off takes — a week is realistic. The design
below is built for the slow case, where a deviation must survive, stay explained, and stay
visible without becoming background noise.

## What Changes

- Add a `design-system-check` skill, run when the design system updates. It reads the newest
  `Medal Wall Design System v*.html`, records its tokens, compares them against the iOS
  token code, and reports what disagrees.
- Add `openspec/design-system/tokens.json`: the tokens the skill read, committed. Its git
  diff is the design system changelog — the artifact that does not exist today, because
  `documents/` is not under version control and each version replaces the last.
- Add `openspec/design-system/deviations.md`: a ledger of deliberate deviations, carrying for
  each one why the code deviates, whether design has been told, and since when. **The iOS
  value wins** for as long as an entry stands; the check never overwrites it.
- Add an `apply` mode that transcribes design system changes into the code — colour sets,
  pigments, radii, spacing, type sizes — while never touching a token the ledger protects.
- Report disagreements within the design system itself, where its Swift, Kotlin, and CSS
  blocks state different values for the same token.
- Remove `TypeScale.microLabel`, now byte-identical to `TypeScale.overline`.
- Correct two errors in `CLAUDE.md` (`ActionStyleViewModifier.swift` →
  `ActionViewModifier.swift`; the missing `.neutral` case), remove the enumerable lists that
  caused them, and add a rule that any session notices a `tokens.json` older than the design
  system folder and offers to run the check.
- Add a standing rule to `docs/development-workflow.md`: run the check when the design system
  updates, and at step 5 (Verify) for any change touching UI.

## Capabilities

### New Capabilities
- `design-system-sync`: reading the design system's tokens, checking the iOS implementation
  against them, recording deliberate deviations, and applying design system changes to the
  code where no deviation stands.

### Modified Capabilities
<!-- None. No app-facing capability changes behavior; the microLabel removal is a
     no-op cleanup of a duplicate constant with no call sites. -->

## Impact

- **New**: `.claude/skills/design-system-check/SKILL.md`,
  `openspec/design-system/tokens.json`, `openspec/design-system/deviations.md`.
- **Modified**: `MedalWall/Shared/Extensions/Font+Extensions.swift` (remove `microLabel`),
  `CLAUDE.md`, `docs/development-workflow.md`.
- **Written by `apply`, only where no ledger entry stands**: the asset catalog colour sets,
  `Color.Pigment`, `CGFloat.Radius`, `CGFloat.Space`, and `Font.TypeScale` values.
- **Never written**: the colour role structs, the modifier enums, and any doc comment. Those
  encode design reasoning rather than transcribed values.
- **Read but never written**: `../../documents/Design System/Medal Wall Design System
  v*.html`. The design system document stays hand-authored.
- **No new languages, dependencies, or build steps.** No app code paths change and nothing
  here ships in the binary.
