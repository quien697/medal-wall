## Why

MedalWall has been under active development with no OpenSpec baseline. There is no
living record of what the app's shipped capabilities actually do, so future change
proposals have nothing to diff against. This change documents the current, already-
implemented behavior as the starting baseline — it does not change any code.

## What Changes

- Document the current behavior of five shipped capabilities as OpenSpec specs.
- No code changes. No behavior changes. This is a documentation-only baseline.

## Capabilities

### New Capabilities
- `races`: Race + RaceEdition CRUD — race identity (name, location, photo, website)
  separated from per-year edition data (date, distances offered).
- `medals`: Medal CRUD — race results archive with placements, division/age group,
  tags, cover photo, and event photo gallery.
- `profile`: Editable user profile (name, bio, photo, gender, birthday) plus computed
  stats (total medals, full/half marathon counts and best times).
- `settings`: Appearance (theme) preference, currently the only implemented setting.
- `auth`: Email link, Google, and Apple sign-in.

### Modified Capabilities
(none — no existing specs to modify; this is the first baseline)

## Impact

None to running code. Establishes `openspec/specs/{races,medals,profile,settings,auth}`
as the baseline that future `openspec new change` proposals (e.g. LINE sign-in,
Settings export/units/notifications, Achievements) will diff against.
