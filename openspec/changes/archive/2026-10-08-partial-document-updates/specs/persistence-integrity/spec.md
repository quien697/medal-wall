## ADDED Requirements

### Requirement: Updates Preserve Unowned Fields
An update to an existing document SHALL write only the fields its model declares, and MUST
leave every other stored field unchanged. Documents are shared with other platform clients,
which may store fields this build does not know about, and an iOS save must not erase them.

An optional field the model no longer holds SHALL be deleted from the stored document, so that
clearing a value removes it rather than leaving the old one behind.

An update SHALL fail when its document no longer exists, rather than recreating it.

Each repository SHALL list the fields its update owns, and a test SHALL fail when the model
gains a stored field missing from that list.

#### Scenario: Another client stored a field this build does not know
- **WHEN** a user saves an edit to their profile, a medal, a race, or an edition whose stored
  document holds a field the iOS model does not declare
- **THEN** that field keeps its stored value after the save

#### Scenario: A user clears an optional value
- **WHEN** a user saves an edit that removes an optional value, such as a profile bio, a
  medal's finish time, or an edition's photo
- **THEN** the stored document no longer holds that field

#### Scenario: The document was deleted elsewhere
- **WHEN** a user saves an edit to a medal or edition that another device has deleted
- **THEN** the save fails, the user is shown the save error, and the document is not recreated

#### Scenario: A model gains a field
- **WHEN** a stored field is added to `User`, `Medal`, `Race` or `RaceEdition` without being
  added to its repository's update field list
- **THEN** a unit test fails
