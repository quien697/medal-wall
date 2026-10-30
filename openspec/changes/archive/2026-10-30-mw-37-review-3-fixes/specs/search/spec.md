## MODIFIED Requirements

### Requirement: Search Data Loading
The Search tab SHALL load the races and the signed-in user's medals each time it appears,
including when the user returns to it from a result's detail screen, and SHALL filter them on
the phone. Leaving the Search screen while a load runs SHALL NOT cancel the load. A load's medals or
races SHALL NOT replace a newer load's, and only the newest load SHALL present an error. While
a reload runs, the results already shown SHALL stay. The Search tab SHALL NOT show skeleton
bones or a loading indicator; a section appears when its data has loaded.

#### Scenario: A change elsewhere is found
- **WHEN** the user adds a race on the Race tab and then opens the Search tab
- **THEN** a query matching the new race lists it

#### Scenario: Returning from a detail screen
- **WHEN** the user opens a race from the results, deletes it, and returns to Search
- **THEN** the deleted race is no longer listed

#### Scenario: An older load finishes last
- **WHEN** a load that started before a race was deleted finishes after the load started on
  returning to Search
- **THEN** the deleted race stays off the list, and the older load presents no error

#### Scenario: A reload keeps results
- **WHEN** the Search tab reappears with results on screen
- **THEN** those results stay until the reload replaces them

#### Scenario: A newer load fails after an older one loaded
- **WHEN** an older load succeeds while a newer load runs, and the newer load's race fetch
  then fails
- **THEN** the older load's races stay searchable, and the race fetch error sheet shows
