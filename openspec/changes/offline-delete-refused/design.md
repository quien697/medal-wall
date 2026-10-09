## Context

`edit-sheet-save-lifecycle` made Edit Medal, Edit Race and Edit Profile check
`NetworkMonitor.isConnected()` before saving and refuse with `AppError.noInternetConnection`.
It listed offline deletes as a non-goal. The three delete paths — `MedalDetailViewModel.deleteMedal`,
`RaceDetailViewModel.deleteRace`, `RacesViewModel.deleteRace(_:)` — have no connection check
and no deleting state, so offline they wait silently for the server.

## Goals / Non-Goals

**Goals:**
- An offline delete is refused up front with the existing "No internet connection" error.

**Non-Goals:**
- A deleting state (spinner, disabled button). Online, a delete answers quickly; the silent
  wait comes only from being offline.
- Edition deletes, which are written by Edit Race's save and already checked there.

## Decisions

### Same check as the saves
Each ViewModel takes an injected `NetworkMonitor` (default `NWPathNetworkMonitor()`) and checks
it at the top of the delete. `deleteMedal` throws `AppError.noInternetConnection`, as it already
throws its failures; the two race deletes set `error`, as they already do. Race Detail closes
only when `error` is nil, so a refused delete keeps it open; Medal Detail closes only when
`deleteMedal` returns.

`MedalDetailView` maps any thrown error to `medalDeleteFailed` today; it changes to
`error as? AppError ?? .medalDeleteFailed`, as `EditMedalView` does for saves.

*Alternative — remove the row or close the screen at once and let the delete land later:*
rejected. If the delete then failed, the medal or race would reappear with no explanation.

## Risks / Trade-offs

- [A connection lost after the check still waits for the server] → the same narrow window as
  the saves; it resolves on reconnect.
