## ADDED Requirements

### Requirement: You Tab Loading
The You tab's statistics and achievements SHALL come from its newest load of the medals. A load
that finishes after a newer load has started SHALL NOT change the medals they come from,
present an error, or end the newer load's loading state, whether it finishes before or after
the newer load.

#### Scenario: An older load finishes last
- **WHEN** a load that started before a medal was deleted finishes after the load that started
  on returning to the You tab
- **THEN** the statistics leave the deleted medal out

#### Scenario: An older load fails last
- **WHEN** an older load fails after a newer load has loaded the medals
- **THEN** no error is shown and the statistics from the newer medals stay

#### Scenario: An older load finishes first
- **WHEN** an older load finishes while a newer load is still running
- **THEN** the tab keeps what it showed before, still loading, until the newer load finishes
