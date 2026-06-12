---
name: new-feature
description: Scaffold a new MVVM feature folder with Views/, ViewModels/, correct MARK sections, and a Preview
disable-model-invocation: true
---

Scaffold `MedalWall/Features/$ARGUMENTS/` with two files:

**`Views/<Name>View.swift`**
- `import SwiftUI`
- `struct <Name>View: View` with `// MARK:` sections in order: `Environment` → `State` → `Properties` → `Body`
- Omit empty sections; skip `// MARK:` entirely if fewer than 5 members
- Annotate every closing brace in `body` with the container name (two spaces before: `}  // VStack`)
- `#Preview` block at the bottom using `@Previewable @State` for any bindings; inject required environment objects

**`ViewModels/<Name>ViewModel.swift`**
- `import Foundation`
- `@Observable final class <Name>ViewModel` with `// MARK:` sections in order: `Data` → `State` → `Dependencies` → `Init` → `Functions`
- Omit empty sections; use `// MARK: - Properties` when ≤ 5 members total
- `isLoading: Bool = false` in State; `defer { isLoading = false }` in any async load function
- Throw `AppError` from functions; never `Error` or raw strings
- All async work via `async/await`; no Combine

Follow CLAUDE.md conventions exactly:
- `@Observable`, never `ObservableObject` / `@Published`
- No force unwrap (`!`)
- No logic or computed properties in the View — all in the ViewModel
- Repositories injected via init, not accessed as singletons
