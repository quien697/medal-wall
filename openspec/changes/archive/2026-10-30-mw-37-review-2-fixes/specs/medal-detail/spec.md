## ADDED Requirements

### Requirement: Medal Detail Reload
When Edit Medal closes, Medal Detail SHALL reload the medal and its record marker, and SHALL
show the result of its newest reload. A reload that finishes after a newer reload has started
SHALL NOT change the medal or the record marker shown, and SHALL NOT present an error.

#### Scenario: An older reload finishes last
- **WHEN** Edit Medal closes twice, and the reload that started the first time finishes after
  the one that started the second time
- **THEN** Medal Detail shows the medal as the second edit left it

#### Scenario: An older reload fails last
- **WHEN** an older reload fails after a newer reload has loaded the medal
- **THEN** no error is shown and the newer medal stays
