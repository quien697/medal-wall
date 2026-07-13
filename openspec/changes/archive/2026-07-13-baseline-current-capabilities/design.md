## Context

MedalWall has no OpenSpec baseline yet, despite being an active, partially-shipped
iOS app (Swift 6, SwiftUI, Firebase/Firestore, MVVM). This change is documentation-
only: it captures existing behavior as specs, not new implementation.

## Goals / Non-Goals

**Goals:**
- Produce one spec per shipped capability (`races`, `medals`, `profile`, `settings`,
  `auth`) that accurately reflects current behavior, verifiable against the code.
- Establish a baseline that future `openspec new change` proposals can diff against.

**Non-Goals:**
- No code changes, no bug fixes, no new features.
- No spec for `achievements` — it has no real implementation (placeholder UI only)
  and its design is an open question (see the project vision doc), so there is no
  shipped behavior to baseline yet.

## Decisions

- **One capability per shipped feature area**, matching the `Features/` folder
  structure, rather than one giant spec — keeps each spec independently reviewable
  and matches how future change proposals will scope their diffs.
- **Capability boundaries follow repositories**, not UI screens: `races` covers both
  `Race` and `RaceEdition` (one repository, `RaceFirestoreRepository`); `medals`
  covers `Medal` and its embedded `EventPhoto`/`Division`/`AgeGroup` types (one
  repository, `MedalFirestoreRepository`).
- **`settings` is baselined as-is (appearance only)**, not as the aspirational
  export/units/notifications feature set — those are future change proposals, not
  part of the baseline.

## Risks / Trade-offs

- [Spec drifts from code over time if not updated] → Mitigation: any future change
  proposal touching a baselined capability must include a spec delta; code review
  should treat an undocumented behavior change as a spec gap.
- [Baseline specs are written from reading the code, not from a formal test suite]
  → Mitigation: kept deliberately close to what's directly observable in models and
  repositories; no speculative behavior is documented.
