# persistence-integrity Specification

## Purpose
Say what the app guarantees about a write once a user has pressed save — that success is
reported only when the Firestore backend accepted it, that a change spanning several
documents lands all at once or not at all, that an update leaves fields other clients stored
untouched, and that the persistence layer is substitutable so these guarantees can be tested
without a backend.
## Requirements
### Requirement: Acknowledged Writes
Every repository write SHALL resolve only once the Firestore backend has accepted it, and
SHALL throw when the backend rejects it. A repository MUST NOT report success for a write
that has merely been queued in the local cache.

This is a deliberate trade against Firestore's offline behaviour. The SDK's local cache makes
a queued write look applied immediately, and its acknowledgement never arrives while the
device is offline. Resolving on the local write is therefore indistinguishable from success
even when a security rule is about to reject it, so the app waits for the server: a save made
offline stays in flight until the device reconnects rather than claiming to have saved.

#### Scenario: The backend rejects a write
- **WHEN** a create or update is rejected by the backend, for example by a security rule
- **THEN** the repository throws, the ViewModel sets its `AppError`, and the user is shown
  the error sheet rather than a successful save

#### Scenario: A write is made while offline
- **WHEN** a user saves while the device has no connection
- **THEN** the save remains in progress and reports neither success nor failure until the
  device reconnects and the backend answers

#### Scenario: A model cannot be encoded
- **WHEN** a model fails to encode to a Firestore document
- **THEN** the repository throws before any write is sent

### Requirement: Atomic Multi-Document Writes
A repository operation that changes more than one document SHALL commit those changes as a
single batch, so that either all of them apply or none do. A partially applied operation MUST
NOT be observable.

#### Scenario: A multi-document commit fails
- **WHEN** any part of a batched operation is rejected by the backend
- **THEN** no document in that operation is changed, and the repository throws

### Requirement: Substitutable Persistence Layer
Each repository SHALL be reachable through a protocol — `MedalRepository`, `RaceRepository`,
`UserRepository` — and every ViewModel and manager that persists data SHALL receive its
repository through `init`, defaulting to the Firestore implementation. A ViewModel MUST NOT
construct a concrete Firestore repository inline, so that its behaviour on success and on
failure can be tested without a backend.

#### Scenario: A ViewModel is tested against a fake repository
- **WHEN** a ViewModel is constructed in a test with an in-memory fake repository
- **THEN** it persists through that fake and no Firestore connection is made

#### Scenario: A failing write is surfaced by the ViewModel
- **WHEN** a fake repository is configured to throw on write and the ViewModel saves
- **THEN** the ViewModel sets the `AppError` for that operation and does not report success

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
