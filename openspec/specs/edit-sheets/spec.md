# edit-sheets Specification

## Purpose
Keep an edit in progress safe on the form sheets that save it — medal, race, race edition and
profile — so a sheet closes only by the user's choice, a save always ends in a visible success
or failure, and a save that cannot reach the server is refused up front.
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
of Save and SHALL disable Cancel, until the save succeeds or fails. On success the sheet SHALL
close. On failure the sheet SHALL show the error and stay open with the edits, so the user can
save again or cancel.

#### Scenario: Save succeeds
- **WHEN** a user saves and every upload and write succeeds
- **THEN** the spinner shows until then, and the sheet closes

#### Scenario: Save fails
- **WHEN** a user saves and an upload or write fails
- **THEN** the error is shown, the spinner gives way to Save, and the edits remain

#### Scenario: Connection drops during a photo upload
- **WHEN** the connection is lost while a photo is uploading
- **THEN** the upload gives up within 30 seconds and the save fails with an error

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
