# achievements Specification

## Purpose
Recognize repeat marathon accomplishments with sticky, count-based milestone badges for
the Full Marathon and Half Marathon distances, shown on the user's Profile. An earned
tier persists against later medal deletion.

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

### Requirement: Sticky Milestone Persistence
The system SHALL persist the highest milestone threshold reached per track on the `User`
record (`highestFullMilestone`, `highestHalfMilestone` — optional, treated as `0` when
unset) using a one-way
monotonic ratchet: after a medal create or edit succeeds, the persisted value is raised to
the live count's tier when higher, and is never lowered.

#### Scenario: Earned tier survives medal deletion
- **WHEN** a user deletes medals so a track's live count falls below a previously reached
  tier threshold
- **THEN** the persisted (displayed) tier remains at the reached tier

#### Scenario: Ratchet only advances on create or edit
- **WHEN** a medal create or edit succeeds and the live count crosses a threshold beyond
  the persisted value
- **THEN** the system writes the higher milestone value to the `User` record
- **AND** a medal deletion never changes the persisted milestone value

#### Scenario: Ratchet is a no-op below the next threshold
- **WHEN** a medal create or edit succeeds but the live count has not crossed a threshold
  beyond the persisted value
- **THEN** the persisted milestone value is unchanged

### Requirement: Displayed Tier and Progress
The system SHALL derive the displayed unlocked tier from the greater of the persisted
milestone and the live medal count, and SHALL compute progress toward the next tier from
the raw live count. Milestone values and computed progress SHALL be clamped to the valid
tier range so an out-of-range persisted or derived count cannot select an invalid tier.

#### Scenario: Live count exceeds persisted value
- **WHEN** the live medal count implies a higher tier than the persisted value (e.g.
  before the ratchet write has synced)
- **THEN** the displayed badge reflects the higher live-derived tier

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
