## MODIFIED Requirements

### Requirement: Implementation Comparison
The check SHALL compare the recorded tokens against the iOS implementation — the asset
catalog colour sets, `CGFloat.Radius`, `CGFloat.Space`, `CGFloat.Tracking`, `Font.TypeScale`,
the border `surfaceStyle` draws and the `Elevation` enum when the code defines one, and, for
the `component` family, the `ActionStyle`, `ActionShape`, `ChipStyle`
and `TagStyle` enums, the pressed and disabled states the action modifier draws, the
`TierBadge`, `Progress` and `Skeleton` colour roles, `ProgressBar`'s height and radius, and
the bone sizes in `BoneSize` — and SHALL assign every token exactly one verdict:

| Verdict | Condition | Reported as |
|---|---|---|
| `match` | present in both, values equal | not reported individually |
| `drift` | present in both, values differ, no ledger entry | a problem |
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

Where a design system token name and its code counterpart differ by convention — `fieldLabel`
against `Field.label`, `numericL` against `Numeric.large`, `label` against `overline` — the
check SHALL resolve them and SHALL say which pairings it applied, so a wrong pairing is
visible rather than hidden.

The check SHALL conclude with an explicit statement of whether any `drift` or
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
- **WHEN** a design system token and its code counterpart are spelled differently
- **THEN** the check pairs them and states the pairing it used

#### Scenario: Everything agrees
- **WHEN** no token has a `drift` or `undeclared lead` verdict
- **THEN** the check says so explicitly rather than reporting nothing
