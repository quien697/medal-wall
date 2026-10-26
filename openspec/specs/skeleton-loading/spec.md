# skeleton-loading Specification

## Purpose
Show what is about to appear while a screen's first load is under way: bones in the shape
of the coming data, in the design system's skeleton colours, in place of a spinner or a
blank screen. Own when bones show, what they look like, and how they appear and move; a
reload keeps the current content instead.
## Requirements
### Requirement: Skeleton on First Load
While a screen's data loads and the screen has nothing to show yet, the system SHALL show
skeleton bones in place of that data. This applies to the You tab, Medals, Races, Race detail's
editions, the race picker in Add Medal, and Edit Race's editions. A screen has nothing to show
until its first load succeeds, so a load retried after a failed first load SHALL show bones
again. When a screen that already shows its content loads again — on returning to its tab, or
after an add, edit or delete — the system SHALL keep that content on screen and replace it with
the new data when it arrives, showing neither bones nor a spinner. These screens SHALL NOT show
a spinner while their data loads. While Races reloads, its races SHALL NOT be swiped to delete,
since the reload's older data would bring back a race deleted meanwhile.

#### Scenario: First load
- **WHEN** a user opens the Medals tab for the first time since the app started and the medals
  take longer than 300 ms to load
- **THEN** bones show in place of the collection until the medals arrive, and the collection
  then replaces them

#### Scenario: Reload with content on screen
- **WHEN** a user returns to the Medals tab after their medals have loaded
- **THEN** the collection stays on screen while it reloads, with no bones and no spinner, and
  updates when the new medals arrive

#### Scenario: Deleting a race during a reload
- **WHEN** a user swipes a race while the Races list reloads
- **THEN** no delete action is offered until the reload completes

#### Scenario: Retry after a failed first load
- **WHEN** a screen's first load failed and the screen loads again
- **THEN** bones show again until that load completes

#### Scenario: Editions in Edit Race
- **WHEN** a user opens Edit Race for an existing race and its editions take longer than 300 ms
  to load
- **THEN** the editions section shows bones until the editions arrive

### Requirement: Bone Appearance
Only data SHALL become bones. Large titles, navigation and toolbar buttons, section titles,
subtitles and the tab bar SHALL show as they do once the data has loaded. Each
bone SHALL sit where the content it stands in for sits, laid out as the screen lays out that
content. A bone for a photo, a medal ring, a seal or a progress bar SHALL take that content's
size and shape. A bone for a line of text, a tag or a chip SHALL be a bar as wide as it,
centred on it, at one height per text style, so every bar of one text style matches and a tag
and a chip match each other. A bone SHALL be filled with `skeleton.onPage` when it sits on the page and
with `skeleton.inCard` when it sits inside a card, and SHALL cover the content's own colours
entirely, including gold and champagne record colours, the navy progress fill and text colours.
A list SHALL show as many rows of bones as fit on screen.

#### Scenario: Section titles stay real
- **WHEN** the You tab shows bones
- **THEN** the "Profile" title, the Settings and More buttons, and the "Achievements" section
  title show as they do once loaded

#### Scenario: Bones follow the screen's layout
- **WHEN** the Races tab shows bones
- **THEN** each bone row is laid out as a race row: a bone in the shape of the race logo,
  followed by bars standing in for the name, place and edition count

#### Scenario: Bars of one text style match
- **WHEN** the race picker shows bones
- **THEN** every race name's bar is one height, every caption's bar is one height, and the
  distance chips' bars are the height of a tag's

#### Scenario: Bones on the page and in a card
- **WHEN** the You tab shows bones
- **THEN** the bones for the header sit on the page in `skeleton.onPage`, and the bones inside
  the statistic and achievement cards use `skeleton.inCard`

#### Scenario: No record colours in bones
- **WHEN** bones stand in for an achievement badge, a progress bar, a medal ring or a personal
  record tag
- **THEN** they show only in the bone colour, with no gold, champagne or navy

#### Scenario: Lists fill the screen
- **WHEN** a list shows bones on a screen of any height
- **THEN** rows of bones fill the list's visible area

### Requirement: Skeleton Timing and Motion
Bones SHALL appear only once a load has lasted 300 ms; until then the area they will fill SHALL
stay empty, and a load that completes sooner SHALL show no bones at all. While shown, bones
SHALL pulse in opacity from 0.6 to 1 over 1.2 s and back, repeating. With Reduce Motion on,
bones SHALL hold still at full opacity.

#### Scenario: Fast load
- **WHEN** a screen's first load completes within 300 ms
- **THEN** its content appears without any bones showing first

#### Scenario: Slow load
- **WHEN** a screen's first load takes longer than 300 ms
- **THEN** the content area stays empty for 300 ms, then shows pulsing bones until the load
  completes

#### Scenario: Reduce Motion is on
- **WHEN** bones show while Reduce Motion is on
- **THEN** they hold still at full opacity instead of pulsing

### Requirement: Photos Load After Bones
Bones SHALL stand in for photos without any spinner. Once a screen shows its content, a photo
that is still downloading SHALL show a spinner inside the photo's shape until it arrives.

#### Scenario: Avatar still downloading
- **WHEN** the profile arrives and the You tab's header replaces its bones while the user's
  photo is still downloading
- **THEN** the avatar shows a spinner inside its circle until the photo arrives

### Requirement: Failed Loads
When a screen's first load fails, its bones SHALL give way to the screen's empty state and the
system SHALL present the error sheet. When a load fails while a screen shows its content, the
content SHALL stay on screen and the system SHALL present the error sheet.

#### Scenario: First load fails
- **WHEN** the Medals tab's first load fails
- **THEN** the bones give way to the "No Medals" empty state and the error sheet is presented

#### Scenario: Reload fails
- **WHEN** a reload of the Races tab fails while it shows races
- **THEN** the races stay on screen and the error sheet is presented

