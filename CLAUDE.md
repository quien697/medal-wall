# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

**Build:** Open `MedalWall.xcodeproj` in Xcode and use `Cmd+B`, or:

```bash
xcodebuild -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 pro' build
```

**Run tests:**

```bash
xcodebuild test -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 pro'
```

**Run a single test:** In Xcode, click the diamond icon next to the test function. From CLI, use `-only-testing`:
```bash
xcodebuild test -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 pro' -only-testing:MedalWallTests/RaceIntegrationTests
```

## Architecture

See `ARCHITECTURE.md` for the full data model and design decisions. Summary:

- **Pattern:** MVVM — Views → ViewModels → Repositories → SwiftData (`ModelContext`)
- **Persistence:** SwiftData only. No Firestore; Firebase is used for authentication only.
- **Auth:** `AuthService` wraps Firebase Auth. `UserManager` holds global user state and is injected via `@Environment` — no singletons.
- **Features** are self-contained folders under `MedalWall/Features/`, each with `Views/` and `ViewModels/`.
- **Shared** components, modifiers, extensions, and error types live in `MedalWall/Shared/`.
- **Repositories** (`Data/`) are thin `ModelContext` wrappers; they do not contain query logic. Complex queries use SwiftData `@Query` directly in views/viewmodels.
- **Draft pattern:** Edit ViewModels use unmanaged draft structs to stage changes; writes only reach SwiftData on explicit save.
- **Computed properties** on SwiftData models live in `+Computed.swift` extensions, handling `Data → UIImage` and `String → Enum` conversions.

## Tech Stack

- Swift 6, iOS 26, pure SwiftUI + SwiftData
- `@Observable` macro (Swift Observation — not legacy `ObservableObject` / Combine)
- Swift Testing framework (`@Test`, `#expect`) — not XCTest
- Firebase iOS SDK (Auth only), GoogleSignIn-iOS

## Tooling

- **swift-format** — handles all formatting automatically (indentation, spacing, line length, import ordering). Config: `.swift-format`. Run via pre-commit hook.
- **SwiftLint** — enforces code quality rules. Config: `.swiftlint.yml`. Runs as an Xcode build phase.

The Code Style rules below cover **structural and architectural conventions** that tools cannot enforce. Formatting details (indentation, spacing) are authoritative in `.swift-format` — when in doubt, defer to the tool.

## Code Style

### View Structure

Organize View properties and sections with `// MARK:` comments in this order. Leave a blank line **before** each `// MARK:` (between sections), but **no blank line after** it (the first item follows immediately):

```swift
// MARK: - Environment
@Environment(UserManager.self) private var userManager
@Environment(\.dismiss) private var dismiss

// MARK: - State
@State private var viewModel = ViewModel()
@State private var errorWrapper: ErrorWrapper?

// MARK: - Namespace        ← only when using matched geometry / zoom transitions
@Namespace private var namespace
private let addItem = "addItem"

// MARK: - Properties       ← stored lets / callbacks that are not @State
private let onCommit: ((Draft) -> Void)?

// MARK: - Init
init(...) { ... }

// MARK: - Body
var body: some View { ... }
```

- Include only the sections that are present; omit empty ones.
- **No computed properties or logic in views.** All derived values belong in the ViewModel.
- **Skip `// MARK:` entirely** for views that have only a `body`, or fewer than five properties alongside a `body` — the annotations add noise without navigation value.

Inside `body`, annotate every closing brace with the container name. Use two spaces before the comment (as swift-format produces):

```swift
VStack {
    ...
}  // VStack

SomeCustomContainer {
    ...
}  // SomeCustomContainer
```

### ViewModel Structure

Organize ViewModel members with `// MARK:` comments in this order, with a blank line **before** each `// MARK:` and **no blank line after** it:

```swift
// MARK: - Data             ← use a label that fits: Data, Filter, etc.
var name: String = ""

// MARK: - State
var isLoading = false
var error: AppError?

// MARK: - Dependencies
let mode: ItemEditMode
private let repository = SomeRepository()

// MARK: - Init
init(...) { ... }

// MARK: - Computed
var isFormValid: Bool { ... }

// MARK: - Functions
/// Saves the current draft.
func save() throws { ... }
```

**Skip `// MARK:` entirely** for ViewModels with fewer than five members where the structure is obvious at a glance.

**Property grouping:** use a single `// MARK: - Properties` when there are 5 or fewer properties. When there are more than 5, split into semantic sections. Common labels:

| Label | Contents |
|---|---|
| `Data` | Mutable form / edit fields |
| `State` | Loading flags, error, transient UI state |
| `Filter` | Search text, selected filters, sort order |
| `Dependencies` | Repositories, services, `mode`, injected values |

Add domain-specific labels as needed (e.g. `Edition Staging`).

Use `///` triple-slash documentation comments on all functions.

### Naming Conventions

- `isPresenting` prefix for state that shows/dismisses a sheet or modal:
  
  ```swift
  @State private var isPresentingPhotoPicker = false
  @State private var isPresentingNewSheet = false
  ```
- File suffixes: `ViewModel.swift`, `Repository.swift`, `+Computed.swift`, `+SampleData.swift`
- `final class` for all repositories, services, and managers
- **View suffix** for screens and sheets (top-level navigable destinations):
  ```swift
  struct LoginView: View { ... }
  struct SignInWithEmailLinkView: View { ... }
  ```
- **Component suffixes** for reusable UI pieces — use a suffix that describes the role:
  - `Card` — self-contained content block with visual boundary
  - `Section` — a logical group within a screen (no border/card chrome)
  - `Header` — title/icon area at the top of a screen or section
  - `Row` — a list or repeating item
  ```swift
  struct EmailSignInHeader: View { ... }
  struct EmailInputSection: View { ... }
  struct RaceCard: View { ... }
  ```
- Each component should live in its own file and be an independent `struct`, not a private computed property on another view.

### Previews

Every View file must include a `#Preview` at the bottom. Use `@Previewable @State` for bindings and inject required environment objects. For views with multiple distinct states (e.g. loading, empty, error), add a named preview per state:

```swift
#Preview("Email Input") {
  @Previewable @State var email = ""
  EmailInputSection(email: $email, isEmailValid: false, onSendLink: {})
}

#Preview("Confirmation") {
  @Previewable @State var email = "you@example.com"
  EmailConfirmationSection(email: email, onDismiss: {})
}
```

### Patterns

- Use `defer { isLoading = false }` for loading state cleanup.
- Store photos as raw `Data` on the model; expose `UIImage` via computed properties in `+Computed.swift`.
- Throw `AppError` from repositories and ViewModels; views present errors via `ErrorWrapper` + `ErrorView`.
- Use `[weak self]` in closures that capture reference types.
