---
name: add-model
description: Scaffold a new Codable model with +Computed.swift and +SampleData.swift in the MedalWall project. Use when the user says "add a model", "create a new model", "scaffold X model", or names a new type to add under Models/. Also use when extending the data layer with a new struct that will be stored in Firestore or embedded in another model.
disable-model-invocation: true
---

Scaffold three files for a new model `$ARGUMENTS`.

## Parse the argument

Accept `$ARGUMENTS` as `ModelName` or `Domain/ModelName`:
- `Award` — ask which domain: `Medal`, `Race`, `User`, or `Shared`
- `Race/Award` — use `Race` as the domain, no need to ask

## Determine the model kind

Before creating files, ask the user one question if the answer isn't obvious from context:

> Is this a **Firestore entity** (stored in its own Firestore collection, needs an `id`) or an **embedded value type** (stored inside another document, no `id`)?

Most new models are Firestore entities. Value types look like `GeoLocation` or `RaceDistance` — small structs embedded in a parent document.

---

## Files to create

### 1. `MedalWall/Models/<Domain>/<ModelName>.swift`

**Firestore entity:**

```swift
//
//  <ModelName>.swift
//  MedalWall
//
//  Created by Quien on <YYYY-MM-DD>.
//

import Foundation

struct <ModelName>: Codable, Identifiable {
  let id: String
  // properties…
  var createdBy: String
  var createdAt: Date
  var updatedAt: Date

  init(
    id: String = UUID().uuidString,
    // parameters…
    createdBy: String,
    createdAt: Date = .now,
    updatedAt: Date = .now
  ) {
    self.id = id
    // assignments…
    self.createdBy = createdBy
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
```

**Embedded value type:**

```swift
//
//  <ModelName>.swift
//  MedalWall
//
//  Created by Quien on <YYYY-MM-DD>.
//

/// One-line description of what this type represents.
struct <ModelName>: Codable, Hashable, Sendable {
  var property: Type
  // …
}
```

**Rules that apply to both:**
- Use the actual date in `YYYY-MM-DD` format
- `let id` is always first and immutable; all other stored properties are `var`
- Optional properties default to `nil`; array properties default to `[]`
- Only `import Foundation` when `Date`, `UUID`, or other Foundation types are used; value types often don't need it
- No `// MARK:` unless the struct has 5+ members

---

### 2. `MedalWall/Models/<Domain>/<ModelName>+Computed.swift`

```swift
//
//  <ModelName>+Computed.swift
//  MedalWall
//
//  Created by Quien on <YYYY-MM-DD>.
//

extension <ModelName> {
  // TODO: add computed properties
}
```

**Rules:**
- No `import` statement — the type is already available
- `///` triple-slash doc comment on each computed property
- Leave a `// TODO:` placeholder if no computed properties are known yet
- For small value types (≤ 4 stored properties), skip this file and put any computed properties inline in the main file instead

---

### 3. `MedalWall/Resources/SampleData/<ModelName>+SampleData.swift`

This file lives under `Resources/SampleData/`, **not** next to the model.

**Firestore entity:**

```swift
//
//  <ModelName>+SampleData.swift
//  MedalWall
//
//  Created by Quien on <YYYY-MM-DD>.
//

import Foundation

extension <ModelName> {
  static let sampleData: [<ModelName>] = {
    [preview]
  }()

  static let preview = <ModelName>(
    id: "<kebab-case-name>-preview",
    // fill required fields with representative placeholder values
    createdBy: "preview"
  )
}
```

**Embedded value type:**

```swift
//
//  <ModelName>+SampleData.swift
//  MedalWall
//
//  Created by Quien on <YYYY-MM-DD>.
//

extension <ModelName> {
  static let preview = <ModelName>(
    // fill required fields
  )
}
```

**Rules:**
- `import Foundation` only when needed (value types often don't need it)
- Placeholder field values should be realistic enough to be useful in previews
- `id` follows the pattern `"<kebab-case-name>-preview"` (e.g. `"award-preview"`)

---

## After creating files

1. List all paths that were created.
2. Remind the user: **new files must be added to the Xcode project target** — Xcode does not auto-include files added outside the IDE. They can drag the files into the Project Navigator or use File → Add Files to "MedalWall".
