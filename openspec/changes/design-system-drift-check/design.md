## Context

The design system lives outside this repo, at `../../documents/Design System/`, as a pair of
hand-authored HTML documents: the system itself and the iOS mockups. `documents/` is not under
version control, and each new version replaces the previous file rather than sitting beside it.
Today this means there is no way to answer "what changed between v4.4 and v4.5?" once the bump
has happened.

`CLAUDE.md` already fixes the direction of authority between two of the three artifacts: when
the token list and an iOS mockup disagree, the token list wins. What it does not cover is the
case that produced this change — the device disagreeing with both, and the code being corrected
first.

Two design system edits landed while this change was being designed, and both shaped it. The
first reordered the document's blocks and replaced the type ramp's format outright. The second
removed the Archivo typeface, turning `archivo(32, .black)` into `.system(32, .black)`. Both
broke a prototype regex extractor; neither would trouble a reader.

The deciding constraint is time-to-resolution. Solo, a deviation lives for an hour, because the
same person fixes the design system. In a team it lives as long as the design hand-off takes,
and a week is realistic. Everything below is built for the slow case; the fast case is the slow
case with the clock run down.

Measured state at the time of writing: of 16 colours, 7 radii, 13 type tokens, and 3 component
enums, everything matches except three deliberate deviations and one duplicate constant.

## Goals / Non-Goals

**Goals:**
- Make drift between the design system and the iOS code visible when the design system moves.
- Let a deliberate iOS deviation survive a slow design hand-off without being mistaken for a
  bug, reverted by a teammate, or forgotten.
- Produce the design system changelog that does not exist today.
- Take hand-transcription of values out of the loop.
- Add no new language, dependency, or build step to a Swift project.

**Non-Goals:**
- A deterministic, gateable tool. See the first decision below, and the CI trigger at the end.
- Checking the iOS mockup document. The mockup is a rendering of the system, not a contract;
  `CLAUDE.md` already subordinates it to the token list.
- Writing to the design system HTML. It is a designed document with prose, rationale, and live
  swatches — not a data file with a skin. The check reports what the design system owes and
  stops there.
- Owning Swift API names. The design system's Swift block prescribes `Font.Step`; the code uses
  `Font.TypeScale`. The ramp values are contract, the struct name is not.

## Decisions

### A skill, not a script

The first draft of this design was a Python extract/check pair. It was rejected after the
evidence arrived: two live design system edits during this change's design broke its regexes,
and both were edits a reader would have absorbed without noticing. Most of that draft's
complexity — locating blocks by content rather than position, asserting a minimum entry count
per family, parsing type typeface-agnostically — existed solely to make a brittle parser fail
loudly instead of silently. Removing the parser does not solve those problems; it deletes them.

The design system is hand-authored HTML that gets restructured freely. That is a bad input for
a regex and a fine input for a reader.

**Trade-off accepted:** two runs may word their reports differently, and this cannot become an
automated gate without being rewritten as code. The condition that would justify that rewrite
is named at the end of this document.

### `tokens.json` lives in `openspec/design-system/`

It sits beside `specs/` and `changes/` rather than under `docs/`, next to the capability spec
that describes it. The OpenSpec CLI is unaffected by a sibling directory. Its git diff is the
only record of what a design system version changed, because each version replaces the last in
a folder that is not under version control.

### Count deltas replace the parser's assertions

A careless reader can drop a token family just as a regex can, so the failure mode the
assertions guarded against does not disappear with them. The check reports per-family counts
against the previous `tokens.json` — `color 16 → 16` — making a family that fell to zero
visible rather than something inferred from an absence.

### The ledger makes the iOS value win, and the check never overwrites it

This is the core of the design. A deviation is recorded once, with its reason and ticket, and
for as long as that entry stands the iOS value is correct: not reported as a problem, not
rewritten by `apply`, not something a teammate should "fix". The reason and ticket fields are
load-bearing for exactly that last case — they are how someone who did not make the decision
understands not to revert it.

### Status, not permanence: the nag targets inaction

An earlier draft split deviations into "owed" (the design system should adopt this) and "local"
(iOS-only forever), with the second going quiet. That was wrong in both directions. Going quiet
is how a temporary decision becomes permanent by accident, and the permanence judgment is hard
to make at the moment a deviation is created.

What actually varies is whether there is anything to *do*. An entry is `unreported` — design
does not know, and someone should tell them — or `reported`, in which case it is waiting on a
release and re-asking about it is noise. So the check asks about `unreported` entries and
merely lists `reported` ones with their age.

Age matters because a dropped hand-off is invisible otherwise. An entry still `reported` two
design system releases after being raised is flagged as stalled. Two is a guess, easy to tune
once it has run against a real team cadence.

Solo this costs nothing: entries resolve before the next run, or are marked `reported` the
moment the same person updates the design system.

### `superseded`: the one case the check refuses to decide

A ledger entry says the iOS value wins *until the design system updates*. When a release finally
names that token with a different value, that condition has been met and the entry's own logic
no longer settles it. The design system has ruled, but the deviation may rest on device evidence
the designer does not have.

So the check reports `superseded`, names both values, and stops. It is the only outcome it
refuses to resolve in either direction. The happy sibling is `resolved` — the release states the
iOS value, and the entry is simply deleted. v4.5 already did this for `ChipStyle` and `TagStyle`,
adopting the code's shape exactly.

### `apply` is bounded by the ledger, not by code layer

An earlier draft bounded `apply` by which code layer it touched — mechanical constants yes, role
structs no. That distinction is still true and still enforced, but it turned out not to be the
interesting one. The ledger already answers the question completely: a token with an entry is
never written, and a token without one is safe to transcribe.

What `apply` buys is the removal of hand-transcription, which is where value errors actually come
from. The 19 `.colorset/Contents.json` files store components as floats in some entries and `0x`
hex in others; nobody should be editing those by hand.

What it must never touch is design reasoning written as code. `Record.primary = Pigment.gilt`
encodes *gold is never tappable*; `TierBadge.lockedInner = Pigment.ash` encodes *no gold until it
is earned*. Regenerating those would keep the values and delete the thinking.

### Two staleness checks, at two costs

`CLAUDE.md` carries a cheap ambient check — glob the folder, compare the version string in the
filename — because every session pays for it. The check's own comparison uses the content hash,
because v4.5 demonstrated that a document can be revised in place without its version moving.
The cheap check catches the common case; the thorough one catches the case that actually bit us.

### `CLAUDE.md` keeps the rules and loses the lists

`CLAUDE.md` was wrong about `ActionStyle`'s cases and about a file's name. Both errors are the
same error: it restated facts that live in code and could not keep them current. It keeps what
only prose can carry — gold is never tappable, shape carries the chip/tag distinction, a fixed
colour needs a fixed counterpart — and drops the enumerations the check now covers.

## Risks / Trade-offs

- **Reports are not reproducible run to run.** → Accepted, and the reason the check is advisory.
  `tokens.json` and the ledger are the durable artifacts; the report is the conversation around
  them.
- **A run could miss a token and nobody would know.** → Count deltas make a shrinking family
  visible. A token changing value while the count holds is still possible to miss, which is why
  `tokens.json` is committed and reviewed as a diff rather than trusted blind.
- **The ledger becomes a place to silence findings.** → Entries require a reason and a ticket,
  `unreported` ones are surfaced every run, and `reported` ones are aged and flagged when stalled.
  Silence has to be earned and does not last.
- **`apply` writes a wrong value confidently.** → It never touches a ledger-protected token,
  never touches the role layer, and presents its changes for review before they are committed.
  `git diff` is the backstop.
- **The rule to run the check can be forgotten.** → The ambient `CLAUDE.md` version comparison
  makes any session notice, which does not depend on anyone remembering.

## Migration Plan

1. Write the skill and run it against the live design system. Commit the resulting
   `tokens.json` as the v4.5 baseline, which is what stops the bleeding.
2. Commit the ledger seeded with its three real entries, each marked `reported` — the design
   system has already been through two revisions with them known.
3. Land the `microLabel` removal, the `CLAUDE.md` corrections and version rule, and the workflow
   rule.

Rollback is deletion: nothing here ships in the binary, and no app code path depends on it.

## When To Promote This To CI

CI was ruled out because a solo project merges its own PRs, so a check nobody runs is caught by
the person who would have run it anyway. **That reasoning expires the moment a second person
edits tokens.** At that point a teammate's undeclared drift should fail their PR rather than wait
for whoever next runs the skill, and the reproducibility the skill gives up becomes worth paying
for.

The trigger is therefore concrete: when more than one person is editing the token layer, port the
`drift` and `undeclared lead` comparisons — and only those, the two that are pure value equality
— into a script and run them on PRs. The skill will by then have shown which comparisons are
worth hardening, which is a better starting point than guessing now.

## Open Questions

- Whether `Font.TypeScale` should be renamed to the design system's `Font.Step`. Out of scope
  here — the ramp values are contract and they already agree.
- Whether `SectionTitleViewModifier` composing `callout` + `.fontWeight(.heavy)` should become a
  named token. It is currently a style the design system does not name. Worth revisiting if more
  such composites appear.
- Whether `Navy950` is genuinely iOS-local. Its reason — fixed ink for content on `champagne`,
  which has no dark slot — applies to every platform, which suggests a gap in the design system
  rather than a customization. Worth settling when it is raised with design.
