## MODIFIED Requirements

### Requirement: Token Capture From The Newest Design System Document
The check SHALL read the design system's tokens from the Claude design canvas named in
`CLAUDE.md` — from every artboard on the canvas page whose name starts "Design System" — and
record them in `openspec/design-system/tokens.json`. The record SHALL cover seven token families —
`color`, `type`, `radius`, `elevation`, `space`, `motion`, and `component` — and SHALL name the canvas,
the page, the version its name states, the artifact version read, and a hash of the page's
artboards.

`tokens.json` is committed, and its diff between runs is the design system's changelog. The
canvas is edited in place, so it is this repo's only record of what a version changed.

#### Scenario: Reading the current version
- **WHEN** the check runs against a Design System page whose artboards hold all seven families
- **THEN** `tokens.json` records every family, and names the canvas, page, version, artifact
  version, and content hash

#### Scenario: The document is restructured between versions
- **WHEN** a new design system version reorders its blocks, moves them between artboards,
  renames artboards, or changes how a family is written
- **THEN** the check still reads every family, because it reads the page rather than
  pattern-matching a fixed layout

#### Scenario: The page is found by its name
- **WHEN** the Design System page is renamed for a new version
- **THEN** the check finds it by the start of its name and records the version the name states

#### Scenario: No single Design System page
- **WHEN** no page, or more than one page, has a name starting "Design System"
- **THEN** the check says so and stops without writing `tokens.json`

#### Scenario: A version is revised in place
- **WHEN** the Design System page's artboards change but its name does not
- **THEN** the recorded content hash changes, so the `tokens.json` diff still shows what moved

#### Scenario: Another page changes
- **WHEN** only an artboard on another page of the canvas changes
- **THEN** the recorded content hash stays the same

### Requirement: Ambient Staleness Check
`CLAUDE.md` SHALL carry a rule that any session notices when `tokens.json` records a version
older than the one the canvas's Design System page name states, and offers to run the check.

This comparison SHALL use the version in the page name rather than the content hash, because
every session pays for it and reading the canvas index is cheap where reading every artboard is
not. The content hash remains the check's own, more thorough, comparison.

#### Scenario: A newer design system version is present
- **WHEN** the Design System page's name states a version newer than `tokens.json` records
- **THEN** the session says so and offers to run the check before continuing UI work

#### Scenario: Versions agree
- **WHEN** `tokens.json` records the version the Design System page's name states
- **THEN** the session continues without comment

### Requirement: Implementation Comparison
The check SHALL compare the recorded tokens against the iOS implementation — the asset
catalog colour sets, `CGFloat.Radius`, `CGFloat.Space`, `CGFloat.Tracking`, `Font.TypeScale`
with `Field`, `Numeric` and `Wordmark`, `Animation.Motion`, the border `surfaceStyle` draws and
the `Elevation` enum when the code defines one, and, for the `component` family, the
`ActionStyle`, `ActionShape`, `ChipStyle` and `TagStyle` enums, the pressed and disabled states
the action modifier draws, the `TierBadge`, `Progress` and `Skeleton` colour roles,
`ProgressBar`'s height and radius, the bone sizes in `BoneSize`, the sizes and shape of
`ImageType`'s medal cases, and the cases of `PhotoSlotContent` with the edges `PhotoSlot` draws
for them — and SHALL assign every token exactly one verdict:

| Verdict | Condition | Reported as |
|---|---|---|
| `match` | present in both, values equal | not reported individually |
| `drift` | present in both, values differ, no ledger entry | a problem |
| `name drift` | present in both, under a different word in code that neither naming convention explains, no ledger entry | a problem |
| `undeclared lead` | in code, absent from the design system, no ledger entry | a problem |
| `declared deviation` | differs from the design system in either shape, and a ledger entry stands | the iOS value wins; reported per its ledger status |
| `unimplemented` | in the design system, absent from code | informational |

A deviation takes two shapes — code carrying a token the design system does not name, and
code holding a different value for a token it does name. The ledger SHALL be able to declare
either.

Values SHALL be compared by what the platform renders, not by how the file spells them. In
particular, a colour set with no dark appearance renders its light value in both modes and
SHALL be treated as equal to a design system token whose light and dark values are the same.

`elevation` SHALL be compared by level name only. The design system states each level as a CSS
`box-shadow`, which SwiftUI cannot express exactly, so the code approximates each level it
builds; a level present in one side and absent from the other is the signal, not its shadow
values. `elevation.hairline`, a border with no shadow, SHALL pair with the border
`surfaceStyle` draws; every other level SHALL pair with a case of `Elevation`.

Names SHALL be compared as well as values. Only two conventions pair a design system name with
a differently written code name, because both keep the same words: a camel-case name split into
a nested type (`fieldLabel` against `Field.label`) and a size letter spelled out (`numericL`
against `Numeric.large`). The check SHALL say which pairings it applied, so a wrong pairing is
visible rather than hidden. Any other difference in name SHALL be reported as `name drift` with
the number of places the code name is used, and SHALL NOT be renamed by the check.

The check SHALL conclude with an explicit statement of whether any `drift`, `name drift` or
`undeclared lead` was found.

#### Scenario: A colour's hex differs between the design system and the asset catalog
- **WHEN** a token's light or dark value differs from its colour set, and no ledger entry
  covers it
- **THEN** the check reports `drift` for that token, naming both values

#### Scenario: A tracking value differs
- **WHEN** the design system's `Tracking.label` differs from `CGFloat.Tracking.label`, and no
  ledger entry covers it
- **THEN** the check reports `drift` for that token, naming both values

#### Scenario: A colour with no dark slot against a token with equal light and dark values
- **WHEN** a colour set has no dark appearance and the design system states the same value
  for light and dark
- **THEN** the check reports `match`, because both render the same colour in both modes

#### Scenario: Code carries a token the design system does not name
- **WHEN** the asset catalog contains a colour set absent from the design system and absent
  from the ledger
- **THEN** the check reports `undeclared lead`

#### Scenario: The design system names a token code has not built
- **WHEN** the design system contains a token with no counterpart in code
- **THEN** the check reports `unimplemented` and does not treat it as a problem

#### Scenario: An elevation level's shadow differs from its CSS value
- **WHEN** an elevation level exists in both the design system and `Elevation`, with different
  shadow values
- **THEN** the check reports `match`, because levels are compared by name

#### Scenario: The code casts no design system shadow
- **WHEN** the code defines no `Elevation`
- **THEN** the check reports every elevation level except `hairline` as `unimplemented`

#### Scenario: Names differ by convention
- **WHEN** a design system token and its code counterpart differ only by nesting or a spelled-out
  size letter
- **THEN** the check pairs them and states the pairing it used

#### Scenario: A token has a different name in code
- **WHEN** a design system token and its code counterpart use different words, as `label` and
  `overline`, and no ledger entry covers it
- **THEN** the check reports `name drift` with both names and how many places use the code
  name, even when the values agree, and renames nothing

#### Scenario: Everything agrees
- **WHEN** no token has a `drift`, `name drift` or `undeclared lead` verdict
- **THEN** the check says so explicitly rather than reporting nothing

### Requirement: Ledger Entries Are Resolved When The Design System Moves
When a design system release changes what it says about a token an entry covers, the check
SHALL classify that entry as one of:

| Outcome | Condition | Action |
|---|---|---|
| `open` | the design system still does not name it, or still differs in the same way | keep the entry; report per status |
| `resolved` | the design system now states the iOS value | delete the entry |
| `superseded` | the design system now names the token and states a *different* value | a decision is required |

The check SHALL delete a `resolved` entry's row from the ledger itself, leaving no note in its
place, and SHALL report each entry it deleted with what the design system now states. Git
history keeps the deleted row.

`superseded` SHALL be reported prominently and SHALL NOT be resolved by the check in either
direction. The condition the entry was written under — the iOS value wins until the design
system updates — has been met, and the design system has ruled differently, so the choice
between them is a human one.

#### Scenario: The design system adopts the iOS value
- **WHEN** a release states the value the ledger entry records for the code
- **THEN** the check deletes the entry's row from `deviations.md` and reports that it did,
  quoting what the design system now states

#### Scenario: The design system rules differently
- **WHEN** a release names a token the ledger covers, with a value different from the code's
- **THEN** the check reports the entry as `superseded`, names both values, and asks for a
  decision rather than choosing

#### Scenario: The design system is still silent
- **WHEN** a release leaves the token as the previous one did
- **THEN** the entry stays `open` and is reported according to its status

### Requirement: Applying Design System Changes To Code
The check SHALL write design system values into the shared token code — the asset catalog
colour sets, `Color.Pigment`, the sizes and weights in `Font.TypeScale`, `Field`, `Numeric` and
`Wordmark`, `CGFloat.Radius`, `CGFloat.Space`, `CGFloat.Tracking`, `Animation.Motion`'s
durations and damping, `ImageType`'s medal sizes, `BoneSize`'s bar heights, and `ProgressBar`'s
height and radius. It SHALL do so only after listing every value it would write, by file, with
its current and design system values, and getting the user's agreement in the same run.

It SHALL NOT write a token covered by a standing ledger entry, in any status. It SHALL NOT write
the colour role structs, the modifier enums, any other case list, a shape, or any doc comment —
those encode design reasoning or behaviour rather than transcribed values — and SHALL NOT add a
token the code does not have.

After writing, it SHALL update any test that pins a written value, build, and run the test
suite, and SHALL leave committing to the user.

#### Scenario: A design system release changes a value the code has not claimed
- **WHEN** a token's value changed in the design system and no ledger entry covers it
- **THEN** the check lists the value with its current and new value, and writes the new value
  into the corresponding code token once the user agrees

#### Scenario: A design system release changes a tracking value
- **WHEN** a tracking value changed in the design system and no ledger entry covers it
- **THEN** the check writes the new value into `CGFloat.Tracking` once the user agrees

#### Scenario: A design system release changes a value the ledger protects
- **WHEN** a token's value changed in the design system and a ledger entry covers it
- **THEN** the check leaves the code unchanged and reports the entry as `superseded`

#### Scenario: Design reasoning is never overwritten
- **WHEN** the check writes code for any reason
- **THEN** the colour role structs, the modifier enums, and all doc comments are left
  untouched

#### Scenario: The user declines
- **WHEN** the user says no to the listed values
- **THEN** no Swift file changes, while `tokens.json` and the ledger are still updated

#### Scenario: The design system adds a case or a token
- **WHEN** the design system names a case, state, shape or token the code does not have
- **THEN** the check reports it and writes nothing for it, leaving it to an OpenSpec change

