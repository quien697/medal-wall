## MODIFIED Requirements

### Requirement: Atomic Multi-Document Writes
A repository operation that changes more than one document SHALL commit those changes as a
single batch, so that either all of them apply or none do. A partially applied operation MUST
NOT be observable. The one exception is a race delete larger than one batch can hold, since
Firestore commits at most 500 writes at once; the `races` capability defines how that delete
is split, so that a partial delete never leaves editions under a deleted race.

#### Scenario: A multi-document commit fails
- **WHEN** any part of a batched operation is rejected by the backend
- **THEN** no document in that operation is changed, and the repository throws

#### Scenario: A race too large for one batch
- **WHEN** a user deletes a race with 500 or more editions
- **THEN** the delete is split into batches as the `races` capability defines, rather than
  refused
