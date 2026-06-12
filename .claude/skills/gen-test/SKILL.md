---
name: gen-test
description: Generate a Swift Testing test file for a ViewModel or Model, placed under MedalWallTests/Unit/ following existing patterns
disable-model-invocation: true
---

Generate a Swift Testing test file for `$ARGUMENTS`.

**Placement**: `MedalWallTests/Unit/<Domain>/<ViewModels|Models>/<Name>Tests.swift`
- Domain matches one of: `Medal`, `Race`, `User`, `Shared`
- Put ViewModel tests under `ViewModels/`, model/value-type tests under `Models/`

**Structure** — mirror existing test files exactly:
```swift
import Testing
@testable import MedalWall

@Suite("<Name> tests")
struct <Name>Tests {

    @Test("description of what it does")
    func testSomething() {
        // arrange
        // act
        // assert with #expect
    }
}
```

**Rules**:
- `import Testing` only — no `import XCTest`
- `@Suite` wraps the whole struct; `@Test` on each function
- Use `#expect(...)` and `#expect(throws:)` — never `XCTAssert*`
- Test function names are plain English descriptions of behavior, not `testDoSomething` camelCase
- For ViewModels: use mock repositories (structs conforming to the repo protocol) — do not instantiate real Firebase dependencies
- Write a failing test first (one that captures the behavior to verify), then stub the rest
- One `@Suite` struct per file; nest with inner `struct` for logical groupings if needed

Ask the user which specific behaviors or edge cases to cover before generating the full suite.
