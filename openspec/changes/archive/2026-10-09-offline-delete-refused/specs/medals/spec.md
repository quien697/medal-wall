## ADDED Requirements

### Requirement: Offline Medal Delete Is Refused
Before deleting a medal, the system SHALL check for a connection. Without one, the delete SHALL
be refused with "No internet connection" before anything is deleted, and the medal SHALL stay
open.

#### Scenario: Delete a medal while offline
- **WHEN** a user confirms deleting a medal with no connection
- **THEN** "No internet connection" is shown, neither the medal nor its photos are deleted, and
  Medal Detail stays open
