## ADDED Requirements

### Requirement: Medal Identity Presentation
The system SHALL open a medal's detail with the medal itself: its photo, wearing the
earned ring, above the race name set as display type. The identity band SHALL carry
nothing else, so the name and the medal are what the screen opens with.

#### Scenario: The medal and its race name open the screen
- **WHEN** a user opens a medal's detail
- **THEN** the medal photo and the race name are presented first, and the location, date
  and bib are not part of that band

#### Scenario: A long race name stays legible
- **WHEN** a race name is too long for one line
- **THEN** it wraps rather than truncating, and the band grows to hold it

### Requirement: Medal Facts List
The system SHALL state a medal's fixed facts as a labelled list: where it was run, when,
at what distance, and under which bib. Each fact SHALL pair a label with its value, and
the distance SHALL also state the race type it was run as.

#### Scenario: The facts are stated in order
- **WHEN** a medal's detail is presented
- **THEN** the location, the date, the distance, and the bib are each stated with their
  own label

#### Scenario: The race type accompanies the distance
- **WHEN** a medal records a distance run in person
- **THEN** the distance fact states both the distance and that it was in person

### Requirement: The Result Is Always Fully Stated
The system SHALL present every result field a medal can hold — finish time, average pace,
overall placement, gender placement, and division placement — whether or not the medal
records them. A field SHALL NOT be hidden because it is unrecorded, so the screen also
tells the user what is still theirs to fill in.

An unrecorded finish time SHALL read as explicitly untimed, in the same wording the
collection list uses. Any other unrecorded field SHALL read as an unfilled value rather
than as a number, and SHALL NOT show a total without a placement to which it belongs.

#### Scenario: A fully recorded medal states every field
- **WHEN** a medal records a finish time, placements and a division
- **THEN** all five result fields present their values

#### Scenario: A medal with only a finish time still shows every field
- **WHEN** a medal records a finish time and nothing else
- **THEN** the finish time is presented, and average pace, overall, gender and division
  are each still present under their labels, shown as unfilled

#### Scenario: An untimed medal says so
- **WHEN** a medal records no finish time
- **THEN** the finish field reads that no time was recorded, rather than an unfilled
  value or a placeholder character

#### Scenario: A total never appears alone
- **WHEN** a medal records a field of total participants but no placement within it
- **THEN** the field reads as unfilled, and the total is not presented on its own

### Requirement: A Placement Is Stated With Its Field
The system SHALL present a placement together with the field it was placed within, as one
fact rather than two — the placement and the size of the field it ran against.

A division placement SHALL name its division group in the field's own label, so the group
and the placement read as one fact. Where a medal records no division group, the field
SHALL still be presented under its plain label.

#### Scenario: A placement states the field it ran against
- **WHEN** a medal records an overall placement of 1058 out of 7373 participants
- **THEN** the overall field presents the placement together with the total it ran against

#### Scenario: A division names its group in the label
- **WHEN** a medal records a division of male 30–34 and a placement within it
- **THEN** the division field's label names that group, and its value is the placement

#### Scenario: A medal with no division still shows the field
- **WHEN** a medal records no division group
- **THEN** the division field is presented under its plain label, shown as unfilled

### Requirement: The Record Marker Is Supplied, Not Derived
The system SHALL mark a medal's finish time with the earned record marker when that medal
holds the personal record for its distance. Because a personal record is a property of the
whole collection and this screen is presented one medal, whether the medal holds a record
SHALL be supplied by whatever opened the screen rather than derived here.

#### Scenario: A record holder is marked
- **WHEN** a medal that holds its distance's record is opened
- **THEN** its finish time carries the record marker

#### Scenario: A medal that holds no record is unmarked
- **WHEN** a medal that does not hold its distance's record is opened
- **THEN** its finish time is presented with no record marker

#### Scenario: Opening from a record's own card marks it
- **WHEN** a medal is opened from the personal best presentation, which only ever presents
  record holders
- **THEN** its finish time carries the record marker

### Requirement: The Day Is Presented As One Band
The system SHALL group what a user captured about the day — the event photos and the note
— under a single heading, rather than as separate bands that each appear and disappear.

#### Scenario: Photos and note appear together
- **WHEN** a medal records both event photos and a note
- **THEN** both are presented under one heading

#### Scenario: One without the other still reads as the day
- **WHEN** a medal records a note but no event photos
- **THEN** the note is presented under that same heading, with no empty photo area

### Requirement: Tags Are Presented As Capsules
The system SHALL present a medal's tags as capsules, the shape reserved for labels that
name something, rather than the rectangular shape reserved for facts a user cannot change.

#### Scenario: A tag is a capsule
- **WHEN** a medal records tags
- **THEN** each tag is presented as a capsule
