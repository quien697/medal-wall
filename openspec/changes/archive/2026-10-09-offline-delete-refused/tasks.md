## 1. Refuse offline deletes (TDD)

- [x] 1.1 Medal — failing test: `deleteMedal` offline throws `noInternetConnection` with no delete and no photo deletes. Then inject `NetworkMonitor` into `MedalDetailViewModel` and check first; existing delete tests inject `StubNetworkMonitor`
- [x] 1.2 Race Detail — failing test: `deleteRace` offline sets `error` to `noInternetConnection` with no delete and no logo deletes. Then inject and check in `RaceDetailViewModel`
- [x] 1.3 Races list — failing test: `deleteRace(_:)` offline sets `noInternetConnection`, deletes nothing and keeps the race in `races`. Then inject and check in `RacesViewModel`
- [x] 1.4 `MedalDetailView` shows a thrown `AppError` as itself

## 2. Verify

- [x] 2.1 Full test suite passes with no new SwiftLint warnings
- [x] 2.2 Manual check: in airplane mode, deleting a medal and a race (detail and list) shows "No internet connection" and leaves it in place
