## ADDED Requirements

### Requirement: Entered Text Is Saved Trimmed
Edit Medal, Edit Race and Edit Profile SHALL save typed text without the whitespace and line
breaks around it: a medal's name, bib number, note and tags; a race's name and website; and a
profile's first name, last name and bio. A medal note, race website or profile bio left blank
SHALL be saved as none. A blank tag, or one the medal already has, SHALL NOT be added. Save
SHALL stay unavailable while a medal's or race's name is blank or its place lacks a country or
a city. Blank means empty, or made only of whitespace and line breaks.

#### Scenario: Text pasted with spaces and a line break
- **WHEN** a user saves a medal whose name is "  Tokyo Marathon" followed by a line break
- **THEN** the medal is saved with the name "Tokyo Marathon"

#### Scenario: A blank optional field
- **WHEN** a user saves a medal note, race website or profile bio that is empty or holds only
  spaces and line breaks
- **THEN** it is saved as none

#### Scenario: A blank name or place
- **WHEN** a medal's or race's name holds only spaces and line breaks, or its place lacks a
  country or a city
- **THEN** Save is unavailable

#### Scenario: A blank or repeated tag
- **WHEN** a user adds a tag that holds only spaces and line breaks, or one the medal already has
- **THEN** no tag is added

## MODIFIED Requirements

### Requirement: Saving State
While Edit Medal, Edit Race or Edit Profile is saving, the sheet SHALL show a spinner in place
of Save and SHALL disable Cancel, until the save succeeds or fails. On success the sheet SHALL
close. On failure the sheet SHALL show the error and stay open with the edits, so the user can
save again or cancel. Each Storage call a save makes — uploading a photo, fetching its link, or
deleting a photo — SHALL give up within 30 seconds when the connection is lost.

#### Scenario: Save succeeds
- **WHEN** a user saves and every upload and write succeeds
- **THEN** the spinner shows until then, and the sheet closes

#### Scenario: Save fails
- **WHEN** a user saves and an upload or write fails
- **THEN** the error is shown, the spinner gives way to Save, and the edits remain

#### Scenario: Connection drops during a photo upload
- **WHEN** the connection is lost while a photo is uploading
- **THEN** the upload gives up within 30 seconds and the save fails with an error

#### Scenario: Connection drops after a photo uploads
- **WHEN** the connection is lost after a photo has uploaded, before its link is fetched
- **THEN** fetching the link gives up within 30 seconds, deleting the uploaded photo is
  attempted, and the save fails with an error

#### Scenario: Connection drops while a removed photo is deleted
- **WHEN** the save's write succeeds and the connection is lost while a removed or replaced
  photo is being deleted
- **THEN** the delete gives up within 30 seconds, the photo is left in storage, and the sheet
  closes
