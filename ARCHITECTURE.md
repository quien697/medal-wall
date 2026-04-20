# Architecture



## Overview

`Medal Wall` follows **MVVM (Model-View-ViewModel)** architecture, with a thin repository layer between the ViewModels and SwiftData persistence. The data flow is unidirectional:

```
Views → ViewModels → Repositories → SwiftData (ModelContext)
```



## Data Models

### Entity Hierarchy

SwiftData `@Model` classes form a three-level hierarchy:

```
User
Race ──── RaceEdition ──── RaceCategory
Medal ──── EventPhoto
```

`Race`, `RaceEdition`, and `RaceCategory` model the event itself. `Medal` is the user's personal record for a specific race distance — it is not directly linked to `Race` in the database.

### SwiftData Models

| Model | Key Properties | Relationships |
|---|---|---|
| `User` | id, firstName, lastName, avatarData, cropAvatarData, bio, gender, birthday | None (root) |
| `Race` | id, name, photoData, cropPhotoData, country, province, city | One-to-many `RaceEdition` (cascade delete) |
| `RaceEdition` | id, year, startDate, endDate, photoData, cropPhotoData | Many-to-one `Race`, one-to-many `RaceCategory` (cascade delete) |
| `RaceCategory` | id, name, distance, type | Many-to-one `RaceEdition` |
| `Medal` | id, name, date, bibNumber, photoData, cropPhotoData, finishTime, raceDistance, tags, placements | Many-to-one `User`, one-to-many `EventPhoto` (cascade delete) |
| `EventPhoto` | id, imageData, caption, sortOrder | Many-to-one `Medal` |

All models use `.unique` constraint on their `id` (UUID) field.

### Value Types

Domain logic is expressed through non-persisted value types:

- **`RaceDistance`** — wraps `RaceDistanceCategory` + `RaceDistanceType`. Implements `Comparable` for sorting.
- **`RaceDistanceCategory`** — enum: `.full`, `.half`, `.10KM`, `.5KM`, `.custom(Double)`
- **`RaceDistanceType`** — enum: `.inPerson`, `.virtual`, `.wheelChair`
- **`Division`** — struct combining gender + age group, serialized as a pipe-separated string in the database.
- **`AgeGroup`** — enum with 20 brackets (five-year up to 40, ten-year above).
- **`RaceLocation`** — struct: country, province, city, district.
- **`RaceEntry`** — ephemeral value type combining Race + RaceEdition + RaceDistance for UI selection during medal creation.

### Computed Properties Pattern

Each SwiftData model has a corresponding `+Computed.swift` extension. These extensions handle:

- **Data → UIImage conversion**: `photoData` and `cropPhotoData` are stored as raw `Data`; the computed `photo` and `cropPhoto` properties convert them to `UIImage`.
- **String → Enum reconstruction**: e.g., `gender` is stored as a `String`, `genderEnum` reconstructs the `Gender` enum.
- **Derived values**: `RaceEdition.distances` aggregates its categories, `Medal.averagePace` calculates from `finishTime` + `raceDistance`.

This keeps SwiftData models simple and avoids storing non-primitive types that SwiftData may not support reliably.



## Repository Layer

Three repositories act as thin wrappers around `ModelContext`:

- **`UserRepository`** — insert, fetch, save for the single `User`.
- **`RaceRepository`** — CRUD for `Race`, `RaceEdition`, and `RaceCategory`.
- **`MedalRepository`** — CRUD for `Medal` and `EventPhoto`.

All repositories share the same pattern:

```swift
class RaceRepository {
    private var context: ModelContext?

    func configure(context: ModelContext) { self.context = context }

    func insertRace(_ race: Race) throws {
        guard let context else { throw AppError.contextNotAttached }
        context.insert(race)
        try context.save()
    }
}
```

Repositories do not contain query logic — SwiftData `@Query` handles fetching directly in ViewModels or Views.



## ViewModels

ViewModels use the `@Observable` macro (Swift Observation framework, not legacy `ObservableObject`). Each ViewModel:

1. Owns one or more repository instances.
2. Receives `ModelContext` via a `configure(context:)` method called by the view on appear.
3. Exposes an `isFormValid` computed property for form validation.
4. Throws errors from save/delete operations, which views catch and display via `AppError`.

### Complex Syncing — EditRaceViewModel

`EditRaceViewModel` demonstrates the most complex update logic: when editing a `Race`, its nested `RaceEdition` list and each edition's `RaceCategory` list must be diffed and synced. The ViewModel:

1. Loads current editions/categories into `DraftRaceEdition` value types.
2. On save, diffs old vs. new state — updates existing, inserts new, deletes removed.
3. This prevents partial writes and keeps SwiftData consistency.

### In-memory Filtering — RacesViewModel

SwiftData predicates do not support complex nested queries well. `RacesViewModel` applies a two-pass approach:

1. A simple `@Query` predicate handles text search.
2. Type/category filtering runs in-memory on the query results.



## Key Design Decisions

### Draft Pattern for Editing

Edit ViewModels (`EditRaceViewModel`, `EditMedalViewModel`) use unmanaged draft structs (`DraftRaceEdition`, `DraftEventPhoto`) instead of editing SwiftData models directly. This means changes only reach the database on explicit save, preventing half-saved states if the user cancels.

### Photo Storage as Data Blobs

Photos are stored as `Data` fields directly on their models (both original and cropped). There is no separate file system storage or asset catalog for user photos. This simplifies persistence and keeps all data in one place, at the cost of larger database files for users with many photos.

### No Race–Medal Relationship

`Medal` stores `raceDistance` as a value type rather than linking to a `RaceCategory` foreign key. This means a user can log a medal for a race that is later deleted or edited, and historical medal data remains intact. Race selection during medal creation is done through the ephemeral `RaceEntry` type, which is discarded after the medal is saved.

### UserManager for Global User State

A single `UserManager` class holds the current `User` and is injected via SwiftUI `@Environment`. ViewModels access `currentUserID` from it when creating medals or filtering user-specific data. This avoids passing the user through every view in the hierarchy.

### Error Handling

All repository and ViewModel operations throw a custom `AppError` enum. Each case includes a localized title, message, and guidance string. Views present errors using SwiftUI alerts via an `ErrorWrapper` + `ErrorView` pattern. This decouples error presentation from business logic.

### App Initialization

`DefaultDataSeeder` runs at launch and checks if tables are empty before inserting default data (a guest `User` and sample `Race`/`Medal` records). Sample data is defined in `+SampleData.swift` extensions on each model to keep the seeder clean.
