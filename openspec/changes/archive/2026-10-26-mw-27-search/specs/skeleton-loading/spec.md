## MODIFIED Requirements

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
