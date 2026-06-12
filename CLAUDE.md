# MedalWall

## Tech Stack
- Swift 6, iOS 26, SwiftUI
- `@Observable` macro (Swift Observation — not legacy `ObservableObject` / Combine)
- Swift Testing framework (`@Test`, `#expect`) — not XCTest
- Firebase iOS SDK: Auth, Firestore, Storage; GoogleSignIn-iOS
- MVVM — Views → ViewModels → Repositories → Firebase
- Firestore for all data; Firebase Storage for images (stored as download URLs on models)

## Project Structure
- `MedalWall/Features/` — self-contained feature folders, each with `Views/` and `ViewModels/`
- `MedalWall/Models/` — `Codable` structs serialized to/from Firestore
- `MedalWall/Repositories/` — async Firestore wrappers (`UserFirestoreRepository`, `RaceFirestoreRepository`, `MedalFirestoreRepository`)
- `MedalWall/Services/` — `AuthService` (Firebase Auth), `StorageService` (Firebase Storage)
- `MedalWall/Managers/` — `UserManager` (global auth + user state, injected via `@Environment`)
- `MedalWall/Shared/` — reusable components, modifiers, extensions, error types
- `MedalWallTests/Unit/` — unit tests organized by domain (Medal, Race, Shared, User)

## Architecture
- All models are `Codable` structs; there is no SwiftData.
- Repositories are stateless — they return values, never hold state.
- ViewModels load data with async calls on appear and hold results in memory; filtering/sorting is done in-memory, not via Firestore query predicates.
- `UserManager` is the single source of truth for auth state and the current `User`; it is injected via `@Environment` — never accessed as a singleton.
- `AuthService` wraps Firebase Auth. `StorageService` handles all Firebase Storage uploads and returns download URLs.
- **Draft pattern:** Edit ViewModels stage changes in local draft structs; writes only reach Firestore on explicit save. `EditRaceViewModel` diffs original vs. draft editions on save (delete → create → update in sequential loops — no `WriteBatch`).
- Photos are uploaded to Firebase Storage via `StorageService`; the download URL is stored as `photoUrl: String?` on the model.
- Throw `AppError` from repositories and ViewModels; views present errors via `ErrorWrapper` + `ErrorView`.
- Error presentation bridge: ViewModels hold `var error: AppError?`; views use `.onChange(of: viewModel.error)` to wrap it in a local `@State var errorWrapper: ErrorWrapper?`, present via `.sheet(item: $errorWrapper) { ErrorView(...) }`, and reset `viewModel.error = nil` on dismiss.

### Data model hierarchy
```
User
Race ──── RaceEdition   (subcollection: races/{id}/editions)
Medal                   (subcollection: users/{uid}/medals)
  └── EventPhoto        (embedded array on Medal)
```

Key value types (not persisted directly): `RaceDistance`, `RaceDistanceCategory`, `RaceDistanceType`, `Division` (space-separated string in Firestore: `"male from30to34"`; parsed by splitting on last space), `GeoLocation`, `RaceEntry` (ephemeral, not `Codable`; bundles `Race` + `RaceEdition` + `RaceDistance` for the race-picker during medal creation).

## Naming
- `isPresenting` prefix for state that shows/dismisses a sheet or modal
- `final class` for repositories, services, and managers
- **View suffix** for screens and sheets: `LoginView`, `RaceDetailView`
- **Component suffixes** by role: `Card`, `Section`, `Header`, `Row`
- File suffixes: `ViewModel.swift`, `Repository.swift`, `+Computed.swift`, `+SampleData.swift`

## Formatting
- `// MARK:` sections: blank line **before**, no blank line **after**
- Annotate every closing brace in `body` with the container name (two spaces before):
  ```swift
  VStack {
      ...
  }  // VStack
  ```

## Comments
- `///` triple-slash on all functions
- `// MARK:` for section organization (skip if fewer than 5 members)

## Patterns
- `defer { isLoading = false }` for loading state cleanup
- `[weak self]` in closures that capture reference types
- No logic or computed properties in views — all derived values belong in the ViewModel
- **Edit ViewModels** take `mode: ItemEditMode` (`.add` / `.edit`) and a nullable model; both add and edit share one ViewModel branching on `mode` in `init` and `save()`.
- **No Race–Medal link:** `Medal` stores `RaceDistance` as a value type, not a foreign key to `Race`. Medals survive race deletion intentionally — do not add `raceId` or cascade-delete medals.
- **Firestore cascade:** Firestore does not cascade-delete subcollections. `deleteRace()` manually fetches and deletes all editions before deleting the race document; any new deletion path must do the same.

## Don'ts
- No force unwrap (`!`)
- No side effects inside `body`
- No direct singleton access — use dependency injection
- No SwiftData (`@Model`, `ModelContext`, `@Query`) — persistence is Firestore only

## Commands
- **Build:** `xcodebuild -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
- **Test:** `xcodebuild test -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
- **Single test:** append `-only-testing:MedalWallTests/<TestClass>/<testMethod>`
- **Lint:** SwiftLint runs automatically as an Xcode build phase; swift-format runs via pre-commit hook

---

## View Structure
`// MARK:` order: `Environment` → `State` → `Namespace` → `Properties` → `Init` → `Body`

Omit empty sections. Skip `// MARK:` entirely for views with only `body` or fewer than 5 properties.

## ViewModel Structure
`// MARK:` order: `Data` → `State` → `Dependencies` → `Init` → `Computed` → `Functions`

Use `// MARK: - Properties` when ≤ 5 members; split into semantic sections beyond that. Common labels: `Data` (form fields), `State` (loading flags, errors), `Filter` (search/sort), `Dependencies` (repos, services, mode).

## Previews
Every View file must include a `#Preview` at the bottom. Use `@Previewable @State` for bindings and inject required environment objects. Add named previews for multiple distinct states (e.g. loading, empty, error).
