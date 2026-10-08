## MODIFIED Requirements

### Requirement: Sticky Milestone Persistence
The system SHALL persist the highest milestone threshold reached per track on the `User`
record (`highestFullMilestone`, `highestHalfMilestone` — optional, treated as `0` when
unset) using a one-way
monotonic ratchet: after a medal create or edit succeeds, the persisted value is raised to
the live count's tier when higher, and is never lowered.

The raise SHALL compare against the value stored on the server at the moment it writes, not
the copy this device loaded, and SHALL write only the two milestone fields. A device holding
an older profile MUST NOT lower a stored milestone. After a raise, the device SHALL hold the
stored values.

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

#### Scenario: A device holds an older milestone
- **WHEN** a medal save on a device whose profile copy holds a lower milestone than the
  server stores computes a tier above the copy but below the stored value
- **THEN** the stored milestone is unchanged
- **AND** the device's profile takes the stored milestone

#### Scenario: Milestone raise fails
- **WHEN** a milestone raise fails, for example because the device is offline
- **THEN** the medal save still succeeds, no error is shown, and the next medal save raises it
