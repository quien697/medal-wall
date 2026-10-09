## Why

A delete is a Firestore write, and writes resolve only once the server accepts them. Offline,
deleting a medal or a race waits until the connection returns, and nothing on screen says so:
Medal Detail and Race Detail stay open after Delete, and a race swiped away in the Races list
stays in the list. The delete lands later, but until then the button looks broken. Saves were
given an up-front connection check in `edit-sheet-save-lifecycle`; deletes were left out.

## What Changes

- Deleting a medal (Medal Detail) or a race (Race Detail, Races list) checks the connection
  first. Offline, the delete is refused with "No internet connection" before anything is
  deleted, and the medal or race stays where it is.
- Medal Detail shows the error it is given instead of always "Couldn't delete medal".

## Capabilities

### New Capabilities

### Modified Capabilities
- `medals`: an offline medal delete is refused up front.
- `races`: an offline race delete is refused up front.

## Impact

- `MedalDetailViewModel`, `RaceDetailViewModel`, `RacesViewModel`: inject `NetworkMonitor`
  (default `NWPathNetworkMonitor()`), check before deleting.
- `MedalDetailView`: show a thrown `AppError` as itself.
- Tests: offline delete refused for each; existing delete tests inject `StubNetworkMonitor`.
