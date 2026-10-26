## Context

Every rule in this change already holds in the code. Most came from code-review fixes that
changed behaviour without a spec delta (MW-32 reviews 6–9); the place conflict came from
`search` (MW-27) matching text that `place-entry` reserves for display. The design system
check gained component tokens in `tokens.json` (v4.5.x–v4.6.0) faster than its spec and skill
described them.

## Goals / Non-Goals

**Goals:**
- Each main spec states what the code does, so a client built from the specs behaves the same.
- One rule for what counts as a recorded finish time, stated once and referenced elsewhere.

**Non-Goals:**
- Changing any behaviour. Where a spec and the code disagree, the spec moves.
- Making a race delete with 500 or more editions atomic.

## Decisions

**A recorded finish time is defined in `medals`.** Every reader of a finish time — the
collection list, medal detail, personal records, profile best times and Edit Medal — goes
through one rule (`Medal.recordedFinishTime`). Stating it in `medals`, which owns the record,
lets `medal-browsing` and `distance-units` reference it rather than each restating a range.
Repeating the range in each spec was the alternative; it lets the copies drift apart.

**Places: narrow the rule rather than change search.** The country code rule exists so that
two records are never judged to be the same place by provider-specific text. Text search does
not judge sameness — it finds what the user reads on screen — so allowing it there keeps the
rule's purpose. Making search match only the country name was the alternative; it would stop
"Taipei" finding a race in New Taipei City, which `search` requires.

**Race delete: describe the batching, keep the code.** Firestore commits at most 500 writes
at once, so atomic deletion of a race with 500 or more editions would need a server-side
function or a soft delete (see the deferred soft-delete decision). Editions are yearly, so no
real race comes near the limit. The spec states the exception and the order that keeps an
interrupted delete safe: the race document goes in the last batch.

**Tracking is applied like spacing and radii.** `CGFloat.Tracking` holds numbers transcribed
from the design system, in the same file as `Radius` and `Space`, which `apply` already writes.
It encodes no design reasoning, unlike the colour roles and modifier enums `apply` never
writes, so it joins the values `apply` writes.

## Risks / Trade-offs

- [The skill and the spec describe the same procedure twice and can drift again] → The skill's
  closing step already asks for a spec change whenever the design system moves; this change
  edits both in one commit.
- [Purpose and design-note edits are made outside the delta] → They are listed as tasks so
  they land in the same change.
