## ADDED Requirements

### Requirement: Token Capture From The Newest Design System Document
The check SHALL read the design system's tokens from the highest-versioned
`Medal Wall Design System v*.html` in the design system folder, and record them in
`openspec/design-system/tokens.json`. The record SHALL cover five token families — `color`,
`type`, `radius`, `space`, and `component` — and SHALL name the source file, its version
string, and a hash of its content.

`tokens.json` is committed, and its diff between runs is the design system's changelog. It is
the only record that survives a design system version being replaced in place.

#### Scenario: Reading the current version
- **WHEN** the check runs against a design system document containing all five families
- **THEN** `tokens.json` records every family, and names the source file, version, and
  content hash

#### Scenario: The document is restructured between versions
- **WHEN** a new design system version reorders its blocks or changes how a family is written
- **THEN** the check still reads every family, because it reads the document rather than
  pattern-matching a fixed layout

#### Scenario: Highest version wins
- **WHEN** the design system folder contains more than one versioned document
- **THEN** the check reads the highest-versioned file and names it in `tokens.json`

#### Scenario: A version is revised in place
- **WHEN** the design system document's content changes but its filename and version string
  do not
- **THEN** the recorded content hash changes, so the `tokens.json` diff still shows what moved

### Requirement: Family Count Reporting
The check SHALL report, for every token family, the number of tokens read against the number
in the previously committed `tokens.json` — for example `color 16 → 16`. A family whose count
falls SHALL be called out explicitly.

This exists because a missed family is the check's own most dangerous failure: it looks like
agreement. Counts make an absence visible instead of leaving it to be inferred.

#### Scenario: A family is read completely
- **WHEN** every family holds the same number of tokens as the previous run
- **THEN** the check reports the counts unchanged and continues

#### Scenario: A family shrinks
- **WHEN** a family holds fewer tokens than the previous run
- **THEN** the check calls out that family by name, with both counts, before reporting
  anything else

#### Scenario: First run with no previous record
- **WHEN** no previous `tokens.json` exists
- **THEN** the check reports the counts it read and notes that it established the baseline

### Requirement: Implementation Comparison
The check SHALL compare the recorded tokens against the iOS implementation — the asset
catalog colour sets, `CGFloat.Radius`, `CGFloat.Space`, `Font.TypeScale`, and the
`ActionStyle`, `ChipStyle`, and `TagStyle` enums — and SHALL assign every token exactly one
verdict:

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

#### Scenario: Code carries a token the design system does not name
- **WHEN** the asset catalog contains a colour set absent from the design system and absent
  from the ledger
- **THEN** the check reports `undeclared lead`

#### Scenario: The design system names a token code has not built
- **WHEN** the design system contains a token with no counterpart in code
- **THEN** the check reports `unimplemented` and does not treat it as a problem

#### Scenario: Names differ by convention
- **WHEN** a design system token and its code counterpart are spelled differently
- **THEN** the check pairs them and states the pairing it used

#### Scenario: Everything agrees
- **WHEN** no token has a `drift` or `undeclared lead` verdict
- **THEN** the check says so explicitly rather than reporting nothing

### Requirement: Deviation Ledger
The check SHALL read `openspec/design-system/deviations.md`, a Markdown table recording
deliberate deviations. Each entry SHALL carry the token, what the code does, what the design
system says, why the code deviates, a status of `unreported` or `reported`, the date it was
raised, and the originating ticket.

**While an entry stands, the iOS value wins.** The check SHALL NOT report it as a problem and
SHALL NOT overwrite it.

The check SHALL report entries by status, because the actionable item is inaction rather than
the deviation itself:

- An `unreported` entry SHALL be surfaced as needing to be raised with design.
- A `reported` entry SHALL be listed with its age, and SHALL NOT be re-litigated. An entry
  still `reported` two or more design system releases after it was raised SHALL be flagged as
  stalled.

#### Scenario: An unreported deviation
- **WHEN** an entry's status is `unreported`
- **THEN** the check surfaces it as needing to be raised with design

#### Scenario: A reported deviation waiting on a release
- **WHEN** an entry's status is `reported` and the design system still does not name the token
- **THEN** the check lists it with its age and does not treat it as a problem

#### Scenario: A reported deviation that has stalled
- **WHEN** an entry has been `reported` across two or more design system releases
- **THEN** the check flags it as stalled, so a dropped hand-off becomes visible

#### Scenario: An entry without a reason
- **WHEN** a ledger entry's reason or ticket is empty
- **THEN** the check reports the entry as incomplete rather than honouring it silently

#### Scenario: A malformed ledger is not silently ignored
- **WHEN** the ledger file is missing or its table cannot be parsed
- **THEN** the check says so rather than treating every deviation as undeclared

### Requirement: Ledger Entries Are Resolved When The Design System Moves
When a design system release changes what it says about a token an entry covers, the check
SHALL classify that entry as one of:

| Outcome | Condition | Action |
|---|---|---|
| `open` | the design system still does not name it, or still differs in the same way | keep the entry; report per status |
| `resolved` | the design system now states the iOS value | delete the entry |
| `superseded` | the design system now names the token and states a *different* value | a decision is required |

`superseded` SHALL be reported prominently and SHALL NOT be resolved by the check in either
direction. The condition the entry was written under — the iOS value wins until the design
system updates — has been met, and the design system has ruled differently, so the choice
between them is a human one.

#### Scenario: The design system adopts the iOS value
- **WHEN** a release states the value the ledger entry records for the code
- **THEN** the check reports the entry as `resolved` and recommends deleting it

#### Scenario: The design system rules differently
- **WHEN** a release names a token the ledger covers, with a value different from the code's
- **THEN** the check reports the entry as `superseded`, names both values, and asks for a
  decision rather than choosing

#### Scenario: The design system is still silent
- **WHEN** a release leaves the token as the previous one did
- **THEN** the entry stays `open` and is reported according to its status

### Requirement: Applying Design System Changes To Code
The check SHALL offer an `apply` mode that writes design system values into the code:
the asset catalog colour sets, `Color.Pigment`, `CGFloat.Radius`, `CGFloat.Space`, and
`Font.TypeScale` values.

`apply` SHALL NOT write a token covered by a standing ledger entry, in any status. It SHALL
NOT write the colour role structs, the modifier enums, or any doc comment — those encode
design reasoning rather than transcribed values.

`apply` SHALL present its changes for review before they are committed.

#### Scenario: A design system release changes a value the code has not claimed
- **WHEN** a token's value changed in the design system and no ledger entry covers it
- **THEN** `apply` writes the new value into the corresponding code token

#### Scenario: A design system release changes a value the ledger protects
- **WHEN** a token's value changed in the design system and a ledger entry covers it
- **THEN** `apply` leaves the code unchanged and reports the entry as `superseded`

#### Scenario: Design reasoning is never overwritten
- **WHEN** `apply` runs for any reason
- **THEN** the colour role structs, the modifier enums, and all doc comments are left
  untouched

### Requirement: Ambient Staleness Check
`CLAUDE.md` SHALL carry a rule that any session notices when `tokens.json` records a version
older than the newest design system document, and offers to run the check.

This comparison SHALL use the version string in the filename rather than the content hash,
because every session pays for it and globbing a folder is cheap where reading a 140 KB
document is not. The content hash remains the check's own, more thorough, comparison.

#### Scenario: A newer design system version is present
- **WHEN** the design system folder holds a version newer than `tokens.json` records
- **THEN** the session says so and offers to run the check before continuing UI work

#### Scenario: Versions agree
- **WHEN** `tokens.json` records the newest version present
- **THEN** the session continues without comment

### Requirement: Design System Internal Consistency
The design system document states its type ramp separately for Swift, Kotlin, and CSS. The
check SHALL compare those statements against one another and report any token whose size or
weight disagrees across them, or that is present in one platform's block and absent from
another.

These findings SHALL be reported in their own section, as defects in the design system rather
than in the code, and SHALL NOT count as `drift` — no single platform block has authority
over the others.

#### Scenario: A token's size disagrees across platforms
- **WHEN** a type token states one size in the Swift block and a different size in the Kotlin
  block
- **THEN** the check reports an internal inconsistency naming both values, in its own section

#### Scenario: Internal inconsistency is not code drift
- **WHEN** the only findings are internal inconsistencies
- **THEN** the check reports the implementation as agreeing with the design system
