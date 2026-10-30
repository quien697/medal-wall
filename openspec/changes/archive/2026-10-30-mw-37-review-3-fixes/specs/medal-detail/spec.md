## MODIFIED Requirements

### Requirement: Medal Detail Reload
When Edit Medal closes, Medal Detail SHALL reload the medal and its record marker. A reload's
result SHALL show unless a newer reload's result has already shown, and only the newest reload
SHALL present an error.

#### Scenario: An older reload finishes last
- **WHEN** Edit Medal closes twice, and the reload that started the first time finishes after
  the one that started the second time
- **THEN** Medal Detail shows the medal as the second edit left it

#### Scenario: An older reload fails last
- **WHEN** an older reload fails after a newer reload has loaded the medal
- **THEN** no error is shown and the newer medal stays

#### Scenario: A newer reload fails after an older one loaded
- **WHEN** an older reload succeeds while a newer one runs, and the newer one then fails
- **THEN** the older reload's medal stays on Medal Detail, and the error shows
