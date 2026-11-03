## MODIFIED Requirements

### Requirement: Medal Identity Presentation
The system SHALL open a medal's detail with the medal itself — its front, presented as the
`medal-photos` capability's medal image at 280 pt, with no earned ring — above the race name
set as display type. The identity band SHALL carry nothing else, so the name and the medal
are what the screen opens with.

When the medal has a back photo, a button in the medal's top-right corner SHALL name the face
in view, FRONT or BACK, and tapping it SHALL flip the medal to the other face. The button
SHALL NOT be shown when the medal has no back. Tapping the medal itself SHALL NOT flip it. The
flip SHALL turn the medal over with `motion.flip`, and SHALL be a fade instead when Reduce
Motion is on. The detail SHALL open on the front.

#### Scenario: The medal and its race name open the screen
- **WHEN** a user opens a medal's detail
- **THEN** the medal's front and the race name are presented first, and the location, date
  and bib are not part of that band

#### Scenario: A long race name stays legible
- **WHEN** a race name is too long for one line
- **THEN** it wraps rather than truncating, and the band grows to hold it

#### Scenario: Flipping to the back
- **WHEN** a medal has a back and the user taps the FRONT button
- **THEN** the medal turns over to show its back, and the button reads BACK

#### Scenario: Flipping back to the front
- **WHEN** the back is in view and the user taps the BACK button
- **THEN** the medal turns over to show its front, and the button reads FRONT

#### Scenario: No back, no button
- **WHEN** a medal has no back photo
- **THEN** no face button is shown and the medal cannot be flipped

#### Scenario: Tapping the medal does not flip it
- **WHEN** a medal has a back and the user taps the medal image itself
- **THEN** the face in view stays the same

#### Scenario: A back without a front
- **WHEN** a medal has a back and no front
- **THEN** the detail opens on the front placeholder, and the FRONT button flips it to the back

#### Scenario: Reduce Motion
- **WHEN** Reduce Motion is on and the user taps the face button
- **THEN** the other face fades in instead of the medal turning over
