## MODIFIED Requirements

### Requirement: Medal Identity Presentation
The system SHALL open a medal's detail with the medal itself — its front, presented as the
`medal-photos` capability's medal image at 280 pt, with no earned ring — above the race name
set as display type. The identity band SHALL carry nothing else, so the name and the medal
are what the screen opens with.

A label in the medal's top-right corner SHALL name the face in view, FRONT or BACK, and
tapping anywhere on the medal SHALL flip it to the other face, whether or not that face has a
photo; a face without one SHALL show its placeholder. The label SHALL have no action of its
own. The flip SHALL turn the medal over with `motion.flip`, and SHALL be a fade instead when
Reduce Motion is on. The detail SHALL open on the front.

#### Scenario: The medal and its race name open the screen
- **WHEN** a user opens a medal's detail
- **THEN** the medal's front and the race name are presented first, and the location, date
  and bib are not part of that band

#### Scenario: A long race name stays legible
- **WHEN** a race name is too long for one line
- **THEN** it wraps rather than truncating, and the band grows to hold it

#### Scenario: Flipping to the back
- **WHEN** a medal's front is in view and the user taps anywhere on the medal
- **THEN** the medal turns over to show its back, and the label reads BACK

#### Scenario: Flipping back to the front
- **WHEN** the back is in view and the user taps anywhere on the medal
- **THEN** the medal turns over to show its front, and the label reads FRONT

#### Scenario: A medal without a back
- **WHEN** a medal has no back photo and the user taps it
- **THEN** the medal turns over to the back's placeholder, and the label reads BACK

#### Scenario: A back without a front
- **WHEN** a medal has a back and no front
- **THEN** the detail opens on the front placeholder, and tapping the medal flips it to the
  back

#### Scenario: Reduce Motion
- **WHEN** Reduce Motion is on and the user taps the medal
- **THEN** the other face fades in instead of the medal turning over
