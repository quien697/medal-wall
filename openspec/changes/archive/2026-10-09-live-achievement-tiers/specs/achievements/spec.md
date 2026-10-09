## MODIFIED Requirements

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

## REMOVED Requirements

### Requirement: Sticky Milestone Persistence
**Reason**: Badges now reflect the medals the user holds. Keeping a tier after its medals are
deleted needed a stored milestone, a second write path to the user document, and a ratchet that
a device holding an older profile could undo (review finding #11).
**Migration**: None. Existing `highestFullMilestone` / `highestHalfMilestone` values stay in
user documents and are ignored.
