# edit-sheets Specification

## Purpose
Keep an edit in progress safe on the form sheets that save it — medal, race, race edition and
profile — so a sheet closes only by the user's choice, a save always ends in a visible success
or failure, a save that cannot reach the server is refused up front, and typed text is saved
without the whitespace around it.
## Requirements
### Requirement: Form Sheets Close Only By Choice
The Edit Medal, Edit Race, Edit Race Edition and Edit Profile sheets SHALL NOT close on a
swipe down. Cancel SHALL be the only way to leave one without saving. A picker sheet opened
from a form — place, distance, race entry — SHALL still close on a swipe down.

#### Scenario: Swipe down mid-edit
- **WHEN** a user swipes down on a form sheet while editing
- **THEN** the sheet stays open with every edit intact

#### Scenario: Cancel
- **WHEN** a user taps Cancel on a form sheet that is not saving
- **THEN** the sheet closes and the edits are discarded

#### Scenario: Swipe down on a picker
- **WHEN** a user swipes down on a picker sheet opened from a form
- **THEN** the picker closes and the form keeps its edits

### Requirement: Saving State
While Edit Medal, Edit Race or Edit Profile is saving, the sheet SHALL show a spinner in place
of Save and SHALL disable Cancel and the form, until the save succeeds or fails. On success the
sheet SHALL close. On failure the sheet SHALL show the error and stay open with the edits, so
the user can save again or cancel. Each Storage call a save makes — uploading a photo, fetching its link, or
deleting a photo — SHALL give up within 30 seconds when the connection is lost.

#### Scenario: Save succeeds
- **WHEN** a user saves and every upload and write succeeds
- **THEN** the spinner shows until then, and the sheet closes

#### Scenario: The form is locked while saving
- **WHEN** a user saves and an upload or write is still in progress
- **THEN** no field, photo or section of the form can be changed until the save ends

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

### Requirement: Offline Save Is Refused
Before saving, Edit Medal, Edit Race and Edit Profile SHALL check for a connection. Without
one, the save SHALL be refused with "No internet connection" before any photo is uploaded or
any record is written, and the sheet SHALL stay open with the edits. Edit Race Edition only
stages its edits for the race's save and is not checked.

#### Scenario: Save while offline
- **WHEN** a user saves with no connection
- **THEN** "No internet connection" is shown, nothing is uploaded or written, and the sheet
  keeps the edits

#### Scenario: Connection lost after the check
- **WHEN** the connection is lost after the check passes, during a Firestore write
- **THEN** the spinner shows until the connection returns and the server answers

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

### Requirement: Photo Slots
Every photo an edit sheet sets — a medal's front and back, the profile photo, a race logo and an
edition photo — SHALL be set through the same photo slot, which offers **Choose Photo**,
**Take Photo**, and **Remove Photo** once there is a photo. While a stored photo downloads, its
slot SHALL show that it is loading. If it cannot be downloaded, the slot SHALL say it couldn't
load and SHALL still offer Choose Photo, Take Photo and Remove Photo. A stored photo that could
not be downloaded SHALL be kept on save unless the user replaces or removes it.

#### Scenario: A stored photo is downloading
- **WHEN** a user opens an edit sheet whose stored photo has not downloaded yet
- **THEN** its slot shows a spinner, not the empty slot

#### Scenario: A stored photo cannot be downloaded
- **WHEN** a stored photo fails to download
- **THEN** its slot says it couldn't load, and tapping it offers Choose Photo, Take Photo and
  Remove Photo

#### Scenario: Removing a photo that couldn't load
- **WHEN** a user removes a stored photo that couldn't load, and saves
- **THEN** the photo is removed as it would be had it loaded

#### Scenario: Saving without touching a photo that couldn't load
- **WHEN** a user saves without replacing or removing a stored photo that couldn't load
- **THEN** the stored photo is kept
