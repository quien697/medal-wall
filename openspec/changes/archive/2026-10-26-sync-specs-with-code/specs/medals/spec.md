## ADDED Requirements

### Requirement: Recorded Finish Time
A stored finish time SHALL count as recorded only when it is greater than zero and less than
1,000 hours. Any other stored value — zero, below zero, 1,000 hours or more, or infinite —
SHALL read everywhere as no finish time: in the collection list, medal detail, personal
records and profile best times. Edit Medal SHALL open such a medal with no finish time, so
saving it removes the stored value. Another client or a corrupt document can store any
number, and a time outside this range is not one anyone ran.

#### Scenario: A zero finish time reads as untimed
- **WHEN** a medal's stored finish time is zero
- **THEN** the collection list and medal detail read that no time was recorded, and no pace
  is shown

#### Scenario: An impossibly long finish time reads as untimed
- **WHEN** a medal's stored finish time is 1,000 hours or more, or infinite
- **THEN** it reads as no finish time everywhere it would appear, and it neither holds a
  personal record nor counts as a best time

#### Scenario: Editing a medal whose finish time is not recorded
- **WHEN** a user opens Edit Medal for a medal whose stored finish time is outside the range
- **THEN** the finish time field is empty, and saving the medal removes the stored value
