## ADDED Requirements

### Requirement: Races List Loading
The Races list SHALL show the result of its newest load. A load that finishes after a newer
load has started SHALL NOT change the races shown, present an error, or end the newer load's
loading state, whether it finishes before or after the newer load.

#### Scenario: An older load finishes last
- **WHEN** a load that started before a race was deleted from Race Detail finishes after the
  load that started on returning to the Races list
- **THEN** the deleted race stays off the list

#### Scenario: An older load fails last
- **WHEN** an older load fails after a newer load has loaded the races
- **THEN** no error is shown and the newer races stay

#### Scenario: An older load finishes first
- **WHEN** an older load finishes while a newer load is still running
- **THEN** the list keeps what it showed before, still loading, until the newer load finishes
