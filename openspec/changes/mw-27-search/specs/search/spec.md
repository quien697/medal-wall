## ADDED Requirements

### Requirement: Search Tab
The system SHALL offer search as its own tab, after You, Medal and Race, declared with the
system's search tab role. The Search tab SHALL be the only place the app offers a search
field for medals or races; the Races list SHALL NOT carry one.

#### Scenario: Search is its own tab
- **WHEN** a signed-in user looks at the tab bar
- **THEN** it offers You, Medal, Race and Search, with Search drawn by the system as its search
  tab

#### Scenario: The Races list has no search field
- **WHEN** a user opens the Race tab
- **THEN** the Races list shows no search field

### Requirement: Empty Field Hint
While the search field is empty, or holds only whitespace and newlines, the system SHALL show
a hint titled "Search Races and Medals" with the description "Find any race by name, city or
country." and nothing else: no results, recent searches, suggestions or filters. The hint
SHALL stay while the field is focused and empty.

#### Scenario: Opening the Search tab
- **WHEN** a user opens the Search tab with an empty field
- **THEN** the hint shows and no medal or race is listed

#### Scenario: Whitespace is an empty query
- **WHEN** a user types only spaces into the field
- **THEN** the hint shows, as for an empty field

#### Scenario: Clearing the field
- **WHEN** a user clears a query that had results
- **THEN** the results are replaced by the hint

### Requirement: Query Matching
The system SHALL match the query — the field's text trimmed of whitespace and newlines —
against the signed-in user's own medals and against every race. A medal or race SHALL match
when the query appears anywhere in its name, or anywhere in its place as the app displays it,
ignoring case and diacritics. Results SHALL update on every change to the field, with no
minimum query length.

#### Scenario: A name matches anywhere in it
- **WHEN** the query is "marathon"
- **THEN** a race named "Soochow International Ultramarathon" matches, as does one named
  "Taipei Marathon"

#### Scenario: A place matches
- **WHEN** the query is "Taipei" and a race named "Banqiao Night Run" displays its place as
  "New Taipei City, Taiwan"
- **THEN** that race matches

#### Scenario: Chinese text matches anywhere in it
- **WHEN** the query is "馬拉松"
- **THEN** a race named "田中馬拉松" matches

#### Scenario: Case and diacritics are ignored
- **WHEN** the query is "zurich"
- **THEN** a race named "Zürich Marathon" matches

#### Scenario: Surrounding whitespace is ignored
- **WHEN** the query is "Taipei " with a trailing space
- **THEN** the results are the same as for "Taipei"

#### Scenario: One character already searches
- **WHEN** the user types a single character
- **THEN** every medal and race containing that character in its name or displayed place is
  listed

#### Scenario: Only the user's own medals are searched
- **WHEN** another user owns a medal whose name matches the query
- **THEN** that medal is not listed

### Requirement: Results Grouping
The system SHALL present the matches in one scrolling list with two sections: "Your
Collection", holding the matching medals, then "Races", holding the matching races. Each
section header SHALL show the number of matches in that section. A section with no matches
SHALL NOT be shown. Neither section SHALL be capped: every match SHALL be listed.

#### Scenario: Both sections match
- **WHEN** the query matches 4 of the user's medals and 12 races
- **THEN** "Your Collection" shows 4 with its 4 medals, followed by "Races" showing 12 with its
  12 races

#### Scenario: Only races match
- **WHEN** the query matches races but none of the user's medals
- **THEN** only the "Races" section shows

#### Scenario: A broad query lists every match
- **WHEN** the query matches 1,846 races
- **THEN** the "Races" header shows 1,846 and all 1,846 races can be scrolled to

### Requirement: Results Ordering
The system SHALL order matches deterministically, independent of the order Firestore
returns documents. Matching medals SHALL be ordered by date, most recent first, two medals
sharing a date ordered by identifier. Matching races SHALL list races whose name matches
before races that match only by place; within each group races SHALL be ordered by name,
A→Z in the user's locale, two races sharing a name ordered by identifier.

#### Scenario: Newest medal first
- **WHEN** medals dated 2017, 2019 and 2018 match
- **THEN** they are listed 2019, 2018, 2017

#### Scenario: Name matches before place matches
- **WHEN** the query is "Taipei", "Taipei Marathon" matches by name and "Banqiao Night Run"
  matches only by its place
- **THEN** "Taipei Marathon" is listed before "Banqiao Night Run" even though "B" sorts
  before "T"

### Requirement: Result Content
Each medal result SHALL show the medal's photo in its gold ring, its name, its date, and its
distance followed by its finish time, or its distance alone when no time is recorded. Each race
result SHALL show the race's photo, its name, its displayed place and its edition count, the
count clamped to zero or more. Results SHALL NOT offer swipe actions.

#### Scenario: A timed medal
- **WHEN** a Full marathon medal finished in 03:30:24 is listed
- **THEN** its row reads "Full · 03:30:24" beneath its name and date

#### Scenario: An untimed medal
- **WHEN** a medal with no recorded finish time is listed
- **THEN** its row shows its distance with no time

#### Scenario: A corrupt edition count
- **WHEN** a matching race's stored edition count is negative
- **THEN** its row shows "0 editions"

### Requirement: No Results
When a non-empty query matches no medal and no race, the system SHALL show the system's
no-results view naming the query. It SHALL NOT be shown while the first load of medals or races
is still running; a reload SHALL NOT hide it.

#### Scenario: Nothing matches
- **WHEN** both loads have finished and the query "Osaka" matches nothing
- **THEN** the no-results view for "Osaka" shows

#### Scenario: Data still arriving
- **WHEN** the user types before the races have loaded for the first time and none of the
  medals match
- **THEN** no no-results view shows, and the "Races" section appears when the races arrive if
  any match

### Requirement: Search Data Loading
The Search tab SHALL load the races and the signed-in user's medals each time it appears,
including when the user returns to it from a result's detail screen, and SHALL filter them on
the phone. Leaving the Search screen while a load runs SHALL NOT cancel the load. While a
reload runs, the results already shown SHALL stay. The Search tab SHALL NOT show skeleton
bones or a loading indicator; a section appears when its data has loaded.

#### Scenario: A change elsewhere is found
- **WHEN** the user adds a race on the Race tab and then opens the Search tab
- **THEN** a query matching the new race lists it

#### Scenario: Returning from a detail screen
- **WHEN** the user opens a race from the results, deletes it, and returns to Search
- **THEN** the deleted race is no longer listed

#### Scenario: A reload keeps results
- **WHEN** the Search tab reappears with results on screen
- **THEN** those results stay until the reload replaces them

### Requirement: Search Load Failure
When the medals or the races fail to load, the system SHALL present the error sheet for that
failure — a medal fetch failure or a race fetch failure — and the data that did load SHALL
stay searchable.

#### Scenario: Races fail, medals load
- **WHEN** the race fetch fails and the medal fetch succeeds
- **THEN** the race fetch error sheet shows, and a query still lists matching medals

### Requirement: Opening A Result
Selecting a medal result SHALL open that medal's detail screen, with its personal-record tag
derived from the user's whole collection rather than from the matches. Selecting a race result
SHALL open that race's detail screen. Both SHALL open on the Search tab's own navigation stack,
keeping the query when the user goes back.

#### Scenario: A slower medal is not promoted by the query
- **WHEN** the user opens a medal that is slower than another medal at its distance, from a
  query that does not match the faster one
- **THEN** its detail screen does not show it as a personal record, as from the Medal tab

#### Scenario: Back to the results
- **WHEN** the user opens a race from the results and goes back
- **THEN** the Search tab shows the same query and its results
