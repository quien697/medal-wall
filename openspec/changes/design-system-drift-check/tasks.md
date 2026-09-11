## 1. Ledger

- [ ] 1.1 Create `openspec/design-system/deviations.md` with the columns Token / Code /
      Design system / Why / Status / Since / Ticket, and a short header stating that the iOS
      value wins while an entry stands
- [ ] 1.2 Seed the three outstanding entries, each `reported` and referencing MW-30:
      `Navy900` (#182738, elevated navy surface behind the PB carousel), `Navy950` (#0F1B2D,
      fixed ink for content on champagne), and `champagne`'s absent dark slot (a fixed colour
      needs a fixed counterpart)
- [ ] 1.3 Note against `Navy950` that it may be a design system gap rather than an iOS
      customization, since `champagne` has no dark slot on any platform

## 2. The skill

- [ ] 2.1 Write `.claude/skills/design-system-check/SKILL.md`, matching the layout of the
      existing project skills, with a read-only default and an `apply` mode
- [ ] 2.2 Define the read procedure: glob the design system folder for the newest version,
      read the five token families, read the code-side tokens, read the ledger
- [ ] 2.3 Define verdict assignment — `match`, `drift`, `undeclared lead`,
      `declared deviation`, `unimplemented` — and the name-map pairings
      (`fieldLabel`/`Field.label`, `numericL`/`Numeric.large`, `label`/`overline`), requiring
      the report to state which pairings it used
- [ ] 2.4 Define ledger-entry outcomes: `open` reported by status, `resolved` when the design
      system adopts the iOS value, `superseded` when it names the token and disagrees — with
      `superseded` never decided by the check
- [ ] 2.5 Define the stalled-entry rule: an entry `reported` across two or more design system
      releases is flagged
- [ ] 2.6 Define the report order: family counts, problems, unreported deviations, reported
      deviations with age, resolved and superseded entries, unimplemented tokens,
      design-system-internal inconsistencies in their own section, then an explicit verdict line
- [ ] 2.7 Define `apply`: writes colour sets, `Color.Pigment`, `CGFloat.Radius`, `CGFloat.Space`,
      and `Font.TypeScale` values; never writes a ledger-covered token, the colour role structs,
      the modifier enums, or any doc comment; presents changes for review before commit
- [ ] 2.8 Specify writing `openspec/design-system/tokens.json` with the source file, version,
      and content hash, and reviewing its diff as the design system changelog

## 3. First run

- [ ] 3.1 Run the skill against the live design system and commit the resulting `tokens.json`
      as the v4.5 baseline
- [ ] 3.2 Confirm the report matches the known current state: three declared deviations, no
      drift, no undeclared leads, and one internal inconsistency (`display` is 32 in the Swift
      and CSS blocks, 28 in the Kotlin block)
- [ ] 3.3 Confirm the first-run path reports establishing a baseline rather than comparing
      against a `tokens.json` that does not yet exist
- [ ] 3.4 Confirm `apply` is a no-op today, since every current difference is ledger-covered

## 4. Code and documentation cleanup

- [ ] 4.1 Remove `TypeScale.microLabel`, now byte-identical to `TypeScale.overline`, after
      confirming it has no call sites
- [ ] 4.2 Correct `CLAUDE.md`: `ActionStyleViewModifier.swift` → `ActionViewModifier.swift`,
      and remove the enumerable case lists for `ActionStyle`, `ChipStyle`, and `TagStyle`,
      keeping the prose rules that only prose can carry
- [ ] 4.3 Add to `CLAUDE.md`: what `tokens.json` and the ledger are, that the iOS value wins
      while an entry stands, and that a deliberate deviation must be declared rather than left
      silent
- [ ] 4.4 Add the ambient staleness rule to `CLAUDE.md`: compare `tokens.json`'s recorded
      version against the newest design system filename, and offer to run the check when they
      differ — filename comparison, not content hash, since every session pays for it
- [ ] 4.5 Add to `docs/development-workflow.md`: run the check when the design system updates,
      and at step 5 (Verify) for any change touching UI; record an intentional deviation in the
      ledger as part of the same change

## 5. Verification

- [ ] 5.1 Run the app build and test suite to confirm the `microLabel` removal broke nothing
- [ ] 5.2 Re-run the skill after the cleanup and confirm the report is unchanged apart from
      `microLabel` no longer appearing
- [ ] 5.3 Verify the shrinking-family path by running against a document with a family removed,
      and confirming the count delta is called out by name
- [ ] 5.4 Verify the ambient staleness rule by pointing `tokens.json` at an older version and
      confirming a fresh session notices before doing UI work
