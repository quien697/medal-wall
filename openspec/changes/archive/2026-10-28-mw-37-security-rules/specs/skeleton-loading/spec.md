## MODIFIED Requirements

### Requirement: Skeleton on First Load
While a screen's data loads and the screen has nothing to show yet, the system SHALL show
skeleton bones in place of that data. This applies to the You tab, Medals, Races, Race detail's
editions, the race picker in Add Medal, and Edit Race's editions. A screen has nothing to show
until its first load succeeds, so a load retried after a failed first load SHALL show bones
again. When a screen that already shows its content loads again — on returning to its tab, or
after an add, edit or delete — the system SHALL keep that content on screen and replace it with
the new data when it arrives, showing neither bones nor a spinner. These screens SHALL NOT show
a spinner while their data loads.

#### Scenario: First load
- **WHEN** a user opens the Medals tab for the first time since the app started and the medals
  take longer than 300 ms to load
- **THEN** bones show in place of the collection until the medals arrive, and the collection
  then replaces them

#### Scenario: Reload with content on screen
- **WHEN** a user returns to the Medals tab after their medals have loaded
- **THEN** the collection stays on screen while it reloads, with no bones and no spinner, and
  updates when the new medals arrive

#### Scenario: Retry after a failed first load
- **WHEN** a screen's first load failed and the screen loads again
- **THEN** bones show again until that load completes

#### Scenario: Editions in Edit Race
- **WHEN** a user opens Edit Race for an existing race and its editions take longer than 300 ms
  to load
- **THEN** the editions section shows bones until the editions arrive
