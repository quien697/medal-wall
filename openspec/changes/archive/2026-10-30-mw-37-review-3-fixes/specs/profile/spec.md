## MODIFIED Requirements

### Requirement: You Tab Loading
The You tab's statistics and achievements SHALL never come from an older load than the one
they already show: a load's medals SHALL be used unless a newer load's medals already are, and
only the newest load SHALL present an error or end the loading state.

#### Scenario: An older load finishes last
- **WHEN** a load that started before a medal was deleted finishes after the load that started
  on returning to the You tab
- **THEN** the statistics leave the deleted medal out

#### Scenario: An older load fails last
- **WHEN** an older load fails after a newer load has loaded the medals
- **THEN** no error is shown and the statistics from the newer medals stay

#### Scenario: An older load finishes first
- **WHEN** an older load finishes while a newer load is still running
- **THEN** its statistics show, and the tab stays loading until the newer load finishes

#### Scenario: A newer load fails after an older one loaded
- **WHEN** an older load succeeds while a newer load runs, and the newer load then fails
- **THEN** the statistics from the older load stay, and the error shows
