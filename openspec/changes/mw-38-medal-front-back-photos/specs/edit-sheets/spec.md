## MODIFIED Requirements

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
