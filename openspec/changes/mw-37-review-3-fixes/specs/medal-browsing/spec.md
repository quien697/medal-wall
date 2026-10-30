## MODIFIED Requirements

### Requirement: Medal List Loading
The Medals list SHALL never replace what it shows with an older load's result: a load's
medals SHALL show unless a newer load's medals have already shown, and only the newest load
SHALL present an error or end the loading state.

#### Scenario: An older load finishes last
- **WHEN** a load that started before a medal was deleted from Medal Detail finishes after the
  load that started on returning to the Medals list
- **THEN** the deleted medal stays off the list

#### Scenario: An older load fails last
- **WHEN** an older load fails after a newer load has loaded the medals
- **THEN** no error is shown and the newer medals stay

#### Scenario: An older load finishes first
- **WHEN** an older load finishes while a newer load is still running
- **THEN** its medals show, and the list stays loading until the newer load finishes

#### Scenario: A newer load fails after an older one loaded
- **WHEN** an older load succeeds while a newer load runs, and the newer load then fails
- **THEN** the older load's medals stay on the list, and the error shows
