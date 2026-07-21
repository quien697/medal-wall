# Development Workflow

> This is the MedalWall projection of my personal baseline, `my-openspec-with-superpowers`
> (quien-wiki) — the source of truth for the general workflow. This doc adds only the
> project-specific rules; when the two disagree, the baseline wins on process and this doc
> wins on MedalWall specifics.

How features and fixes get built in MedalWall. It combines two tools:

- **OpenSpec** owns the durable artifacts: the *proposal*, the *design*, the *task
  breakdown*, and the living *specs* under `openspec/specs/`.
- **Superpowers** owns the *discipline*: brainstorming before design, test-driven
  development while implementing, and verification before claiming done.

They are complementary, not redundant. There is **one** set of planning artifacts per
change (OpenSpec's), never a parallel copy under `docs/superpowers/`.

## The loop

For any meaningful feature, subsystem, or bug fix:

1. **Brainstorm** (`superpowers:brainstorming`) — conversational. Agree on the design
   before any artifact is written. Do **not** let brainstorming auto-save a spec to
   `docs/superpowers/specs/`; the design goes into the OpenSpec change instead (step 2).
2. **Create an OpenSpec change** (`openspec-propose`, or `opsx:propose`). This produces,
   under `openspec/changes/<change-id>/`:
   - `proposal.md` — Why / What Changes / Impact
   - `design.md` — Context / Goals & Non-Goals / Decisions / Risks & Trade-offs
   - `specs/<capability>/spec.md` — the spec **delta** (the actual contract, as
     `Requirement` + `Scenario` blocks)
   - `tasks.md` — the implementation plan, as a checklist. **`tasks.md` is the plan.**
     Do not also produce a separate Superpowers plan doc.
3. **Iterate until clean.** Review the proposal and delta for placeholders,
   contradictions, and scope. (`openspec validate` is a CLI command — see *Tooling*
   below; we run skills-only, so the propose/update skills carry the validation.)
4. **Implement each task with TDD** (`superpowers:test-driven-development`): write a
   failing test, make it pass, refactor — one `tasks.md` item at a time, checking each
   off as it lands. Follow project conventions in `CLAUDE.md`.
   - *Per-task exception:* when a task has no unit-testable surface (e.g. a pure
     SwiftUI animation or layout), state that explicitly and verify it another way
     (preview, `verify` skill) rather than writing a test that asserts nothing.
5. **Verify** (`superpowers:verification-before-completion`) — run the build and test
   suite, confirm the change actually works. Evidence before claims. Optionally
   `/code-review` before merge.
6. **Archive** (`openspec-archive-change`, or `opsx:archive`) — folds the change's spec
   delta into `openspec/specs/<capability>/spec.md`, the living record of what the app
   does. Update the capability's `Purpose` if the archive left it as `TBD`.

## When to skip OpenSpec

OpenSpec is for meaningful, reviewable units of work. Skip it for trivial changes —
typo fixes, tiny tweaks, dependency bumps — and just make the change (still with a test
when there's a testable surface). If a "small" change turns out to alter documented
behavior in `openspec/specs/`, stop and open a change so the spec stays honest.

One change per meaningful feature or subsystem step (e.g. `add-skeleton-loading`), not
one giant change for a whole roadmap.

## Reconciliation rules

- **Single source of truth.** The OpenSpec `proposal.md` + `design.md` are the design
  record; `tasks.md` is the plan. No parallel spec or plan under `docs/superpowers/`.
- **Superpowers contributes discipline, not artifacts** — brainstorming, TDD,
  verification, code review.
- **Specs track code.** Any change that alters a baselined capability must include a
  spec delta. Treat an undocumented behavior change as a spec gap in review.
- `docs/superpowers/specs/` and `docs/superpowers/plans/` are **historical** (the
  design-system, vision, and achievements work). Leave them as-is; don't add to them.

## Tooling

- The `openspec` **CLI is not installed**. We run the workflow through the Skills:
  `openspec-propose` / `openspec-update-change` / `openspec-apply-change` /
  `openspec-sync-specs` / `openspec-archive-change` (and their `opsx:*` aliases).
- Project context for OpenSpec generation lives in `openspec/config.yaml` (`context:`
  and `rules:`). Keep it aligned with `CLAUDE.md`.
- To enable the `openspec validate`/`list`/`archive` **CLI** commands later:
  `npm install -g openspec`. Optional; only if the skills prove insufficient.
