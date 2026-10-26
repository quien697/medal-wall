## Why

A check of every main spec against the code found five places where a spec says less than,
or something other than, what the app does. Android and web clients will build from these
specs, so a rule the iOS code enforces but no spec states will not be enforced there.

## What Changes

- **Places:** the country code stays the only value used to group places or to decide that
  two places are the same, and text search may match a place as the app displays it. Today
  `place-entry` forbids any use of the city for filtering, while `search` matches it.
- **Race delete:** a race with up to 499 editions is deleted in one commit, all or nothing.
  A larger race is deleted in batches of up to 499 editions with the race in the last batch,
  so a delete that fails partway leaves the race with fewer editions, never editions under a
  deleted race. `races` and `persistence-integrity` currently promise one commit for any race.
- **Finish times:** a stored finish time counts as recorded only when it is above zero and
  under 1,000 hours. Any other value reads everywhere as no finish time, and Edit Medal opens
  it empty, so saving removes it.
- **Personal records and pace:** a medal holds a personal record only with a recorded finish
  time and a distance that is a positive, finite number. There is no pace without both, or
  when the pace is 1,000 minutes per unit or slower.
- **Design system check:** the comparison covers every token family `tokens.json` records,
  including `CGFloat.Tracking` and the component tokens added since the check was specified,
  and `apply` writes tracking values as it does spacing and radii.

No app code changes: each rule above is already how the app behaves.

## Capabilities

### New Capabilities
_None._

### Modified Capabilities
- `place-entry`: Canonical Place Representation lets text search match the displayed place.
- `races`: Race Management states how a race larger than one batch is deleted.
- `persistence-integrity`: Atomic Multi-Document Writes names the race delete as its one
  exception.
- `medals`: adds Recorded Finish Time.
- `medal-browsing`: Personal Record Derivation also requires a positive, finite distance and
  takes its finish time rule from `medals`.
- `distance-units`: Pace Expressed In The Active Unit states when there is no pace.
- `design-system-sync`: Implementation Comparison covers tracking and every component token;
  Applying Design System Changes To Code writes tracking.

## Impact

- **Specs only**, plus `.claude/skills/design-system-check/SKILL.md`, which carries the
  check's procedure and gains the same tracking and component coverage.
- Three main specs get their `Purpose` written (`design-system-sync`, `medal-detail`,
  `medal-browsing`), and the `achievements` design notes are reduced to the final decision.
  These are edited directly in the main specs, since a delta cannot change those sections.
- No code, Firestore schema, design-token or dependency changes.
