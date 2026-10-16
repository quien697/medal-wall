## ADDED Requirements

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
