# MedalWall

## Tech Stack
- Swift 6, iOS 26, SwiftUI
- `@Observable` macro (Swift Observation — not legacy `ObservableObject` / Combine)
- Swift Testing framework (`@Test`, `#expect`) — not XCTest
- MVVM — Views → ViewModels → Repositories → Firebase
- Firestore for all data; Firebase Storage for images (stored as download URLs on models)

## Design System
The visual baseline lives outside this repo, in `../../documents/Design System/`
(absolute: `~/Code/Personal/Projects/medal-wall/documents/Design System/`):
- **`Medal Wall Design System v*.html`** — the source of truth for colour, type,
  spacing/radius/elevation, components, and the `color.*` token list.
- **`Medal Wall iOS v*.html`** — iOS screen mockups (login, medal wall, medal detail,
  races) showing how those tokens compose per screen.

Filenames are versioned and get renamed, so glob the folder rather than hardcoding a
name, and check the newest version before treating anything as current. Tokens are
platform-neutral by design (iOS asset catalog / Android `colors.xml` / CSS) — keep them
that way. Code-side tokens: `Colors+Extensions.swift`, `Fonts+Extensions.swift`,
`CGFloat+Extensions.swift` (`.Radius`), `ControlStyleViewModifier.swift`
(`ActionStyle` / `ChipStyle`), `ElevationViewModifier.swift`.

## Development Workflow
Features and non-trivial fixes follow the combined OpenSpec + Superpowers loop:
brainstorm → OpenSpec change (`proposal` + `design` + spec delta + `tasks`) → implement
each task with TDD → verify → archive the change into `openspec/specs/`. OpenSpec owns
the planning artifacts (one set per change, no parallel `docs/superpowers/` copy);
Superpowers provides the discipline (brainstorming, TDD, verification). Skip OpenSpec
for trivial changes. Full details: `docs/development-workflow.md`.

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
- **`View` suffix is for screens and sheets only** (a full screen or presented modal): `LoginView`, `RaceDetailView`
- **In-screen components take a role suffix, never `View`**: `Card`, `Section`, `Header`, `Row`, `Badge` — e.g. `AchievementBadge`, not `AchievementBadgeView`
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
- **Guard numeric values against out-of-range inputs.** Never assume persisted (Firestore) or externally-derived numbers sit in the expected range — clamp counts/indices/progress to valid bounds (e.g. `max(0, count)`) so a corrupt or malicious value can't produce negative counts, overflow past a max tier, or index out of bounds. Cover these edge cases with tests.
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
