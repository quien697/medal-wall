## MODIFIED Requirements

### Requirement: Atomic Multi-Document Writes
A repository operation that changes more than one document SHALL commit those changes as a
single batch, so that either all of them apply or none do. A partially applied operation MUST
NOT be observable. A race's delete is no exception: a race holds at most 200 editions (the
`races` capability's Edition Limit), so the race and all of its editions fit one batch, within
Firestore's 500 writes per commit.

#### Scenario: A multi-document commit fails
- **WHEN** any part of a batched operation is rejected by the backend
- **THEN** no document in that operation is changed, and the repository throws

#### Scenario: A race at the edition limit
- **WHEN** a user deletes a race with 200 editions
- **THEN** the race and all 200 editions are deleted in one commit
