# achievements Specification

## Purpose
Recognize repeat marathon accomplishments with count-based milestone badges for the Full
Marathon and Half Marathon distances, shown on the user's Profile. A badge reflects the
medals the user holds now, so it follows medal deletion down as well as new medals up.

## Requirements
### Requirement: Milestone Achievement Tracks
The system SHALL provide two independent milestone tracks — Full Marathon and Half
Marathon — each measured against a shared, ordered list of seven tiers: First Finish (1),
Hat Trick (3), High Five (5), Perfect Ten (10), Quarter Century (25), Half Century (50),
and Centurion (100). 10K, 5K, and custom distances are not tracked.

#### Scenario: Both tracks always shown
- **WHEN** a user views their Profile
- **THEN** both the Full Marathon and Half Marathon tracks are displayed, even when a
  track has zero qualifying medals

#### Scenario: Tier reached at threshold
- **WHEN** a track's qualifying medal count reaches a tier threshold
- **THEN** that tier becomes the track's current unlocked tier

### Requirement: Displayed Tier and Progress
The system SHALL derive a track's unlocked tier from its live medal count — the qualifying
medals the user holds now — and SHALL compute progress toward the next tier from the same
count. Nothing about a track SHALL be stored. The count and computed progress SHALL be
clamped to the valid tier range so an out-of-range count cannot select an invalid tier.

#### Scenario: Deleting medals lowers the tier
- **WHEN** a user deletes medals so a track's live count falls below a tier threshold they
  had reached
- **THEN** the displayed badge drops to the tier the remaining medals reach

#### Scenario: Adding a medal raises the tier
- **WHEN** a medal save brings a track's live count to a tier threshold
- **THEN** the displayed badge shows that tier

#### Scenario: Progress toward next tier
- **WHEN** a track has an unlocked tier below Centurion
- **THEN** the system shows the raw live count against the next tier's threshold

#### Scenario: Maxed track
- **WHEN** a track has reached the Centurion tier
- **THEN** no next-tier progress is shown

#### Scenario: Locked track
- **WHEN** a track has zero qualifying medals
- **THEN** the track shows a locked badge and progress toward First Finish

### Requirement: Quiet Unlocking
The system SHALL unlock tiers quietly, with no toast, sheet, or notification at the moment
a threshold is crossed; the badge reflects the new state the next time Profile is viewed.

#### Scenario: No celebration on unlock
- **WHEN** a medal save causes a track to cross a tier threshold
- **THEN** no notification or celebration UI is presented
- **AND** the updated badge appears on the next Profile view

## Design Notes
Rationale carried over from the 2026-07-14 milestone-achievements design, kept here because
it explains choices the requirements above do not justify on their own.

**One shared tier list, not per-track curves.** Full marathons are harder to accumulate than
halves, but a single threshold list was chosen over two tuned curves for simplicity. Centurion
(100) is deliberately kept as a lifelong-goal cap for full marathons rather than lowered or
removed.

**Badges evolve in ornamentation, not in metal colour.** A single badge shape gains detail
layers as the tier rises. Gold/silver/bronze is deliberately not used here — that colour
language belongs to real race placement (`overallPlacement`, `divisionPlacement`), and reusing
it for milestone counts would blur two different ideas.

**Tiers come from the live count; nothing is stored.** Until 2026-10-09 an earned tier was
sticky: a milestone stored on the `User` record kept it against later medal deletion. That cost
a second write path to the user document after every medal save, and a device holding an older
profile could overwrite the stored value downward. Badges now reflect the medals the user
holds. Old `highestFullMilestone` / `highestHalfMilestone` values remain in some user documents
and are ignored.

**Self-reported data is out of scope, not overlooked.** Fabricated medals are not guarded
against because the whole `Medal` model is self-reported — bib number, finish time, and
placement have no verification against an official results feed. This is not a gap unique to
achievements.

**Deferred deliberately.** A full achievement system — Majors club, streaks, personal-best
achievements — is blocked on canonical race identity: races are freeform manual entries with
no link to a race registry, so "ran all 6 Majors" cannot be reliably detected. Also deferred:
milestone tracks for 10K/5K/custom distances, any celebration or notification UI on unlock,
and verification handling for medal data in general.
