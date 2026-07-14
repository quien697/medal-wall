# Marathon Milestone Achievements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add sticky, count-based milestone achievements ("First Finish" through
"Centurion") for the Full Marathon and Half Marathon tracks, and wire them into
`ProfileView` for the first time.

**Architecture:** Achievement state is computed on the fly from medals already
loaded on Profile (`AchievementProgress.compute`), combined with a small
one-way "ratchet" of two `Int` fields persisted on `User` so an earned tier
survives later medal deletion. The ratchet only ever runs after a medal
create/edit succeeds, never after a delete, and never blocks or fails the
medal save itself.

**Tech Stack:** Swift 6, SwiftUI, `@Observable`, Swift Testing, Firebase
Firestore (via existing `UserFirestoreRepository` / `MedalFirestoreRepository`).

**Spec:** `docs/superpowers/specs/2026-07-14-marathon-milestone-achievements-design.md`

## Global Constraints

- No force unwrap (`!`).
- No logic or computed properties in SwiftUI view `body` — derived values belong in a ViewModel.
- `final class` for repositories/services/managers; `@Observable` for ViewModels/managers holding state.
- Swift Testing (`@Test`, `#expect`) — not XCTest.
- `///` triple-slash doc comment on every function.
- `// MARK:` section headers: blank line **before**, no blank line **after**; skip `// MARK:` entirely for types with fewer than 5 members.
- Annotate every closing brace in a view's `body` with the container name, two spaces before: `}  // VStack`.
- Every `View` file ends with a `#Preview` (named previews for multiple distinct states).
- No SwiftData — Firestore is the only persistence layer.
- Build: `xcodebuild -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
- Test: `xcodebuild test -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
- Single test: append `-only-testing:MedalWallTests/<TestClass>/<testMethod>`

---

### Task 1: `AchievementTier` enum

**Files:**
- Create: `MedalWall/Models/Achievement/AchievementTier.swift`
- Test: `MedalWallTests/Unit/Achievement/Models/AchievementTierTests.swift`

**Interfaces:**
- Produces: `enum AchievementTier: Int, CaseIterable` with cases `firstFinish = 1`, `hatTrick = 3`, `highFive = 5`, `perfectTen = 10`, `quarterCentury = 25`, `halfCentury = 50`, `centurion = 100`; computed `var name: String`; computed `var threshold: Int`.

- [ ] **Step 1: Write the failing test**

Create `MedalWallTests/Unit/Achievement/Models/AchievementTierTests.swift`:

```swift
//
//  AchievementTierTests.swift
//  MedalWall
//
//  Created by Quien on 2026-07-14.
//

import Testing

@testable import MedalWall

struct AchievementTierTests {

  @Test("allCases is ordered ascending by threshold")
  func testAllCasesOrderedAscending() {
    let thresholds = AchievementTier.allCases.map { $0.threshold }

    #expect(thresholds == [1, 3, 5, 10, 25, 50, 100])
  }

  @Test("threshold matches each tier's raw value")
  func testThresholds() {
    #expect(AchievementTier.firstFinish.threshold == 1)
    #expect(AchievementTier.hatTrick.threshold == 3)
    #expect(AchievementTier.highFive.threshold == 5)
    #expect(AchievementTier.perfectTen.threshold == 10)
    #expect(AchievementTier.quarterCentury.threshold == 25)
    #expect(AchievementTier.halfCentury.threshold == 50)
    #expect(AchievementTier.centurion.threshold == 100)
  }

  @Test("name matches expected display string for each tier")
  func testNames() {
    #expect(AchievementTier.firstFinish.name == "First Finish")
    #expect(AchievementTier.hatTrick.name == "Hat Trick")
    #expect(AchievementTier.highFive.name == "High Five")
    #expect(AchievementTier.perfectTen.name == "Perfect Ten")
    #expect(AchievementTier.quarterCentury.name == "Quarter Century")
    #expect(AchievementTier.halfCentury.name == "Half Century")
    #expect(AchievementTier.centurion.name == "Centurion")
  }
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `xcodebuild test -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MedalWallTests/AchievementTierTests`
Expected: FAIL — `AchievementTier` does not exist / build error.

- [ ] **Step 3: Write the minimal implementation**

Create `MedalWall/Models/Achievement/AchievementTier.swift`:

```swift
//
//  AchievementTier.swift
//  MedalWall
//
//  Created by Quien on 2026-07-14.
//

import Foundation

/// Milestone tiers for marathon completion-count achievements, shared by the
/// Full Marathon and Half Marathon tracks.
enum AchievementTier: Int, CaseIterable {
  case firstFinish = 1
  case hatTrick = 3
  case highFive = 5
  case perfectTen = 10
  case quarterCentury = 25
  case halfCentury = 50
  case centurion = 100

  /// Display name shown in the achievement row.
  var name: String {
    switch self {
    case .firstFinish: return "First Finish"
    case .hatTrick: return "Hat Trick"
    case .highFive: return "High Five"
    case .perfectTen: return "Perfect Ten"
    case .quarterCentury: return "Quarter Century"
    case .halfCentury: return "Half Century"
    case .centurion: return "Centurion"
    }
  }

  /// The medal count required to reach this tier.
  var threshold: Int { rawValue }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `xcodebuild test -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MedalWallTests/AchievementTierTests`
Expected: PASS (3 tests).

- [ ] **Step 5: Commit**

```bash
git add MedalWall/Models/Achievement/AchievementTier.swift MedalWallTests/Unit/Achievement/Models/AchievementTierTests.swift
git commit -m "feat: add AchievementTier milestone enum"
```

---

### Task 2: `AchievementProgress` computation

**Files:**
- Create: `MedalWall/Models/Achievement/AchievementProgress.swift`
- Test: `MedalWallTests/Unit/Achievement/Models/AchievementProgressTests.swift`

**Interfaces:**
- Consumes: `AchievementTier` (Task 1) — `.allCases`, `.threshold`.
- Produces: `struct AchievementProgress: Equatable` with `unlockedTier: AchievementTier?`, `nextTier: AchievementTier?`, `currentCount: Int`, `isMaxed: Bool`; `static func compute(persistedMilestone: Int, liveCount: Int) -> AchievementProgress`; `static func ratchetedMilestone(persisted: Int, liveCount: Int) -> Int`.

- [ ] **Step 1: Write the failing test**

Create `MedalWallTests/Unit/Achievement/Models/AchievementProgressTests.swift`:

```swift
//
//  AchievementProgressTests.swift
//  MedalWall
//
//  Created by Quien on 2026-07-14.
//

import Testing

@testable import MedalWall

struct AchievementProgressTests {

  // MARK: - compute
  @Test("compute with zero medals shows no unlocked tier and First Finish as next")
  func testComputeZeroMedals() {
    let progress = AchievementProgress.compute(persistedMilestone: 0, liveCount: 0)

    #expect(progress.unlockedTier == nil)
    #expect(progress.nextTier == .firstFinish)
    #expect(progress.currentCount == 0)
    #expect(progress.isMaxed == false)
  }

  @Test("compute exactly at a threshold unlocks that tier")
  func testComputeExactlyAtThreshold() {
    let progress = AchievementProgress.compute(persistedMilestone: 0, liveCount: 1)

    #expect(progress.unlockedTier == .firstFinish)
    #expect(progress.nextTier == .hatTrick)
    #expect(progress.currentCount == 1)
  }

  @Test("compute between thresholds unlocks the lower tier")
  func testComputeBetweenThresholds() {
    let progress = AchievementProgress.compute(persistedMilestone: 0, liveCount: 7)

    #expect(progress.unlockedTier == .highFive)
    #expect(progress.nextTier == .perfectTen)
    #expect(progress.currentCount == 7)
  }

  @Test("compute at the max tier has no next tier and is maxed")
  func testComputeMaxed() {
    let progress = AchievementProgress.compute(persistedMilestone: 100, liveCount: 100)

    #expect(progress.unlockedTier == .centurion)
    #expect(progress.nextTier == nil)
    #expect(progress.isMaxed == true)
  }

  @Test("compute keeps the persisted tier when live count has dropped below it")
  func testComputePersistedHigherThanLive() {
    let progress = AchievementProgress.compute(persistedMilestone: 10, liveCount: 7)

    #expect(progress.unlockedTier == .perfectTen)
    #expect(progress.nextTier == .quarterCentury)
    #expect(progress.currentCount == 7)
  }

  @Test("compute reflects a live count not yet ratcheted into the persisted value")
  func testComputeLiveHigherThanPersisted() {
    let progress = AchievementProgress.compute(persistedMilestone: 0, liveCount: 12)

    #expect(progress.unlockedTier == .perfectTen)
    #expect(progress.nextTier == .quarterCentury)
    #expect(progress.currentCount == 12)
  }

  // MARK: - ratchetedMilestone
  @Test("ratchetedMilestone never decreases the persisted value")
  func testRatchetNeverDecreases() {
    let result = AchievementProgress.ratchetedMilestone(persisted: 10, liveCount: 7)

    #expect(result == 10)
  }

  @Test("ratchetedMilestone bumps the persisted value up when live count crosses a new tier")
  func testRatchetBumpsUp() {
    let result = AchievementProgress.ratchetedMilestone(persisted: 0, liveCount: 12)

    #expect(result == 10)
  }

  @Test("ratchetedMilestone is a no-op when live count hasn't crossed a new tier")
  func testRatchetNoOp() {
    let result = AchievementProgress.ratchetedMilestone(persisted: 5, liveCount: 7)

    #expect(result == 5)
  }

  @Test("ratchetedMilestone is zero when there are no medals yet")
  func testRatchetZeroMedals() {
    let result = AchievementProgress.ratchetedMilestone(persisted: 0, liveCount: 0)

    #expect(result == 0)
  }
}
```

- [ ] **Step 2: Run the test to verify it fails**

Run: `xcodebuild test -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MedalWallTests/AchievementProgressTests`
Expected: FAIL — `AchievementProgress` does not exist / build error.

- [ ] **Step 3: Write the minimal implementation**

Create `MedalWall/Models/Achievement/AchievementProgress.swift`:

```swift
//
//  AchievementProgress.swift
//  MedalWall
//
//  Created by Quien on 2026-07-14.
//

import Foundation

/// The displayed achievement state for one milestone track (e.g. Full Marathon).
struct AchievementProgress: Equatable {
  let unlockedTier: AchievementTier?
  let nextTier: AchievementTier?
  let currentCount: Int
  let isMaxed: Bool
}

extension AchievementProgress {
  /// Computes displayed progress from the user's persisted sticky milestone and
  /// the live medal count. The unlocked tier is taken from whichever of the two
  /// is higher, so newly-earned tiers show immediately even before the ratchet
  /// (`UserManager.refreshAchievementMilestones`) has persisted them; the
  /// persisted value alone is what protects a tier against later medal
  /// deletion. Progress toward the next tier always uses the live count.
  static func compute(persistedMilestone: Int, liveCount: Int) -> AchievementProgress {
    let effectiveMilestone = max(persistedMilestone, liveCount)
    let unlockedTier = AchievementTier.allCases.last { $0.threshold <= effectiveMilestone }
    let nextTier = AchievementTier.allCases.first { $0.threshold > effectiveMilestone }

    return AchievementProgress(
      unlockedTier: unlockedTier,
      nextTier: nextTier,
      currentCount: liveCount,
      isMaxed: nextTier == nil
    )
  }

  /// Ratchets a persisted milestone upward to match the live count, if the live
  /// count has crossed a new tier threshold. Never decreases the persisted value.
  static func ratchetedMilestone(persisted: Int, liveCount: Int) -> Int {
    let liveTierThreshold = AchievementTier.allCases.last { $0.threshold <= liveCount }?.threshold ?? 0
    return max(persisted, liveTierThreshold)
  }
}
```

- [ ] **Step 4: Run the test to verify it passes**

Run: `xcodebuild test -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MedalWallTests/AchievementProgressTests`
Expected: PASS (10 tests).

- [ ] **Step 5: Commit**

```bash
git add MedalWall/Models/Achievement/AchievementProgress.swift MedalWallTests/Unit/Achievement/Models/AchievementProgressTests.swift
git commit -m "feat: add AchievementProgress computation and ratchet"
```

---

### Task 3: Persist sticky milestones on `User`

**Files:**
- Modify: `MedalWall/Models/User/User.swift`

**Interfaces:**
- Produces: `User.highestFullMilestone: Int?`, `User.highestHalfMilestone: Int?` (both default `nil`, meaning 0 — matches the existing optional-field pattern used for `bio`, `photoUrl`, etc. so old Firestore documents without these keys decode cleanly).

No new test: these are plain optional stored properties with no logic, matching the existing untested fields on `User` (`photoUrl`, `bio`, `gender`, `birthday`). The logic that uses them is already covered by `AchievementProgressTests` (Task 2).

- [ ] **Step 1: Add the two fields and update both initializers**

In `MedalWall/Models/User/User.swift`, add the two new properties after `updatedAt` and thread them through both initializers:

```swift
struct User: Codable {
  let uid: String
  let email: String?
  var firstName: String?
  var lastName: String?
  var photoUrl: String?
  var bio: String?
  var gender: Gender?
  var birthday: Date?
  let createdAt: Date
  var updatedAt: Date?
  var highestFullMilestone: Int?
  var highestHalfMilestone: Int?

  /// Creates a new User from Firebase Auth on first sign-in.
  /// firstName/lastName are seeded separately from the provider via UserDefaults.
  init(firebaseUser: FirebaseAuth.User) {
    uid = firebaseUser.uid
    email = firebaseUser.email
    firstName = nil
    lastName = nil
    photoUrl = nil
    bio = nil
    gender = nil
    birthday = nil
    createdAt = Date()
    updatedAt = nil
    highestFullMilestone = nil
    highestHalfMilestone = nil
  }

  /// Creates a User with explicit field values for use in previews and tests.
  init(
    uid: String,
    email: String?,
    firstName: String? = nil,
    lastName: String? = nil,
    photoUrl: String? = nil,
    bio: String? = nil,
    gender: Gender? = nil,
    birthday: Date? = nil,
    createdAt: Date = .now,
    updatedAt: Date? = nil,
    highestFullMilestone: Int? = nil,
    highestHalfMilestone: Int? = nil
  ) {
    self.uid = uid
    self.email = email
    self.firstName = firstName
    self.lastName = lastName
    self.photoUrl = photoUrl
    self.bio = bio
    self.gender = gender
    self.birthday = birthday
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.highestFullMilestone = highestFullMilestone
    self.highestHalfMilestone = highestHalfMilestone
  }
}
```

- [ ] **Step 2: Build to verify it compiles**

Run: `xcodebuild -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add MedalWall/Models/User/User.swift
git commit -m "feat: persist sticky milestone counts on User"
```

---

### Task 4: Ratchet in `UserManager`

**Files:**
- Modify: `MedalWall/Managers/UserManager.swift`

**Interfaces:**
- Consumes: `AchievementProgress.ratchetedMilestone(persisted:liveCount:)` (Task 2), `Medal.fullCount`/`Medal.halfCount` (existing, `Medal+Stats.swift`), `User.highestFullMilestone`/`highestHalfMilestone` (Task 3), `UserFirestoreRepository.updateUser(_:)` (existing).
- Produces: `UserManager.refreshAchievementMilestones(medals: [Medal]) async` — never throws (swallows its own errors), no-ops if there's no signed-in user or nothing changed.

No new test: `UserManager` has no existing test file (its other Firestore-touching methods — `updateUser`, `loadOrFetchUser` — aren't unit tested either, since they require a live Firestore backend). The ratchet math itself is already covered by `AchievementProgressTests` (Task 2).

- [ ] **Step 1: Add the method**

In `MedalWall/Managers/UserManager.swift`, add this method to the `// MARK: - Functions` section, directly after `updateUser(_:photo:)`:

```swift
  /// Ratchets the user's persisted milestone counts upward based on live medal
  /// counts, never decreasing an already-earned tier. Call after a medal is
  /// created or edited; never after a delete.
  func refreshAchievementMilestones(medals: [Medal]) async {
    guard let user = currentUser else { return }

    let newFullMilestone = AchievementProgress.ratchetedMilestone(
      persisted: user.highestFullMilestone ?? 0, liveCount: medals.fullCount)
    let newHalfMilestone = AchievementProgress.ratchetedMilestone(
      persisted: user.highestHalfMilestone ?? 0, liveCount: medals.halfCount)

    guard newFullMilestone != (user.highestFullMilestone ?? 0)
      || newHalfMilestone != (user.highestHalfMilestone ?? 0) else { return }

    var updated = user
    updated.highestFullMilestone = newFullMilestone
    updated.highestHalfMilestone = newHalfMilestone

    do {
      try await repository.updateUser(updated)
      self.currentUser = updated
    } catch {}
  }
```

- [ ] **Step 2: Build to verify it compiles**

Run: `xcodebuild -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add MedalWall/Managers/UserManager.swift
git commit -m "feat: ratchet achievement milestones in UserManager"
```

---

### Task 5: Trigger the ratchet from the medal save flow

**Files:**
- Modify: `MedalWall/Features/Medal/EditMedal/ViewModels/EditMedalViewModel.swift:124-181` (the `save(by:)` method)
- Modify: `MedalWall/Features/Medal/EditMedal/Views/EditMedalView.swift:120-134` (the save button's Task)

**Interfaces:**
- Consumes: `UserManager.refreshAchievementMilestones(medals:)` (Task 4), `MedalFirestoreRepository.fetchMedals(userId:)` (existing).
- Produces: `EditMedalViewModel.save(by userID: String, userManager: UserManager) async throws` (signature changed — added `userManager` parameter).

No new test: `EditMedalViewModelTests.swift` (existing) has no test that calls `save(by:)` today, since it requires a live Firestore backend — this task doesn't change that file.

- [ ] **Step 1: Change the `save` signature and add the post-save ratchet call**

In `MedalWall/Features/Medal/EditMedal/ViewModels/EditMedalViewModel.swift`, replace the `save(by:)` method (lines 123–181):

```swift
  /// Saves the medal to Firestore, uploading any new photos to Firebase Storage first,
  /// then ratchets the user's achievement milestones based on the updated medal list.
  func save(by userID: String, userManager: UserManager) async throws {
    isLoading = true
    defer { isLoading = false }
    let location = GeoLocation(
      country: country,
      province: province.isEmpty ? nil : province,
      city: city,
      district: district.isEmpty ? nil : district
    )

    let photoUrl = try await resolvedPhotoUrl(userId: userID)
    let eventPhotos = try await resolvedEventPhotos(userId: userID)

    if let medal, mode == .edit {
      var updated = medal
      updated.name = name
      updated.date = date
      updated.bibNumber = bibNumber
      updated.photoUrl = photoUrl
      updated.location = location
      updated.distance = distance
      updated.finishTime = finishTime
      updated.overallPlacement = overallPlacement
      updated.totalParticipants = totalParticipants
      updated.division = division?.rawValue
      updated.divisionPlacement = divisionPlacement
      updated.divisionTotal = divisionTotal
      updated.genderPlacement = genderPlacement
      updated.genderTotal = genderTotal
      updated.note = note.isEmpty ? nil : note
      updated.tags = tags
      updated.eventPhotos = eventPhotos
      try await repository.updateMedal(updated)
    } else {
      let newMedal = Medal(
        id: medalId,
        name: name,
        date: date,
        bibNumber: bibNumber,
        photoUrl: photoUrl,
        location: location,
        distance: distance,
        finishTime: finishTime,
        overallPlacement: overallPlacement,
        totalParticipants: totalParticipants,
        division: division,
        divisionPlacement: divisionPlacement,
        divisionTotal: divisionTotal,
        genderPlacement: genderPlacement,
        genderTotal: genderTotal,
        note: note.isEmpty ? nil : note,
        tags: tags,
        eventPhotos: eventPhotos,
        userID: userID
      )
      try await repository.createMedal(newMedal)
    }

    do {
      let medals = try await repository.fetchMedals(userId: userID)
      await userManager.refreshAchievementMilestones(medals: medals)
    } catch {}
  }
```

The trailing `do`/`catch {}` deliberately swallows failures — a failed achievement refresh must never surface as a medal-save error, since the medal itself already saved successfully.

- [ ] **Step 2: Update the call site**

In `MedalWall/Features/Medal/EditMedal/Views/EditMedalView.swift`, change line 127:

```swift
                  try await viewModel.save(by: userID, userManager: userManager)
```

- [ ] **Step 3: Build to verify it compiles**

Run: `xcodebuild -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Run the existing EditMedalViewModel tests to verify no regression**

Run: `xcodebuild test -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:MedalWallTests/EditMedalViewModelTests`
Expected: PASS (all existing tests, unchanged).

- [ ] **Step 5: Commit**

```bash
git add MedalWall/Features/Medal/EditMedal/ViewModels/EditMedalViewModel.swift MedalWall/Features/Medal/EditMedal/Views/EditMedalView.swift
git commit -m "feat: ratchet achievement milestones after a medal save"
```

---

### Task 6: Expose achievement progress from `ProfileViewModel`

**Files:**
- Modify: `MedalWall/Features/Profile/Profile/ViewModels/ProfileViewModel.swift`

**Interfaces:**
- Consumes: `AchievementProgress.compute(persistedMilestone:liveCount:)` (Task 2), `User` (Task 3 fields).
- Produces: `ProfileViewModel.fullMarathonProgress(user: User?) -> AchievementProgress`, `ProfileViewModel.halfMarathonProgress(user: User?) -> AchievementProgress`.

No new test: both methods are one-line pass-throughs to the already-tested `AchievementProgress.compute`, matching the existing untested status of `ProfileViewModel`'s other computed stats (`fullCount`, `bestFullTime`, etc., which delegate to already-tested `Medal+Stats.swift`).

- [ ] **Step 1: Add the two methods**

In `MedalWall/Features/Profile/Profile/ViewModels/ProfileViewModel.swift`, add a `// MARK: - Functions` section (after the existing `loadMedals`) with:

```swift
  /// Computes Full Marathon achievement progress from the loaded medals and the given user's persisted milestone.
  func fullMarathonProgress(user: User?) -> AchievementProgress {
    AchievementProgress.compute(persistedMilestone: user?.highestFullMilestone ?? 0, liveCount: fullCount)
  }

  /// Computes Half Marathon achievement progress from the loaded medals and the given user's persisted milestone.
  func halfMarathonProgress(user: User?) -> AchievementProgress {
    AchievementProgress.compute(persistedMilestone: user?.highestHalfMilestone ?? 0, liveCount: halfCount)
  }
```

The full file after this change:

```swift
//
//  ProfileViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-04-18.
//

import SwiftUI

@Observable
final class ProfileViewModel {
  // MARK: - Data
  var medals: [Medal] = []

  // MARK: - Dependencies
  private let repository = MedalFirestoreRepository()

  // MARK: - Computed
  var totalMedals: Int { medals.count }
  var fullCount: Int { medals.fullCount }
  var halfCount: Int { medals.halfCount }
  var bestFullTime: String { medals.bestFullTime?.formattedHMS ?? "-" }
  var bestHalfTime: String { medals.bestHalfTime?.formattedHMS ?? "-" }

  // MARK: - Functions
  /// Loads all medals for the given user from Firestore.
  func loadMedals(userId: String) async {
    medals = (try? await repository.fetchMedals(userId: userId)) ?? []
  }

  /// Computes Full Marathon achievement progress from the loaded medals and the given user's persisted milestone.
  func fullMarathonProgress(user: User?) -> AchievementProgress {
    AchievementProgress.compute(persistedMilestone: user?.highestFullMilestone ?? 0, liveCount: fullCount)
  }

  /// Computes Half Marathon achievement progress from the loaded medals and the given user's persisted milestone.
  func halfMarathonProgress(user: User?) -> AchievementProgress {
    AchievementProgress.compute(persistedMilestone: user?.highestHalfMilestone ?? 0, liveCount: halfCount)
  }
}
```

- [ ] **Step 2: Build to verify it compiles**

Run: `xcodebuild -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Commit**

```bash
git add MedalWall/Features/Profile/Profile/ViewModels/ProfileViewModel.swift
git commit -m "feat: compute achievement progress in ProfileViewModel"
```

---

### Task 7: `AchievementBadgeView` (evolving badge)

**Files:**
- Create: `MedalWall/Features/Profile/Profile/Views/AchievementBadgeView.swift`

**Interfaces:**
- Consumes: `AchievementTier` (Task 1), `Color.Text.tertiary` / `Color.Gold.primary` (existing, `Colors+Extensions.swift`).
- Produces: `struct AchievementBadgeView: View` with `let tier: AchievementTier?` — renders the locked state for `nil`, and an increasingly-ringed badge for each successive tier (validated visual direction: "evolving badge," not gold/silver/bronze color tiers).

No new test: SwiftUI views in this codebase have no unit tests, only `#Preview`s (see `ProfileAchievementRow.swift`, `ProfileSummarySection.swift` — neither has a test file).

- [ ] **Step 1: Create the view**

Create `MedalWall/Features/Profile/Profile/Views/AchievementBadgeView.swift`:

```swift
//
//  AchievementBadgeView.swift
//  MedalWall
//
//  Created by Quien on 2026-07-14.
//

import SwiftUI

/// Renders an evolving badge for an achievement tier — one more ring appears
/// per successive tier. A nil tier renders the locked (not-yet-unlocked) state.
struct AchievementBadgeView: View {
  let tier: AchievementTier?

  private var ringCount: Int {
    guard let tier, let index = AchievementTier.allCases.firstIndex(of: tier) else { return 0 }
    return index + 1
  }

  private var tintColor: Color {
    tier == nil ? Color.Text.tertiary : Color.Gold.primary
  }

  var body: some View {
    ZStack {
      ForEach(0..<ringCount, id: \.self) { index in
        Circle()
          .strokeBorder(tintColor, lineWidth: 2)
          .padding(CGFloat(index * 5))
      }  // ForEach

      Image(systemName: tier == nil ? "star" : "star.fill")
        .font(.title2)
        .foregroundStyle(tintColor)
    }  // ZStack
    .frame(width: 56, height: 56)
  }
}

#Preview("Locked") {
  AchievementBadgeView(tier: nil)
}

#Preview("Tier 1 - First Finish") {
  AchievementBadgeView(tier: .firstFinish)
}

#Preview("Tier 4 - Quarter Century") {
  AchievementBadgeView(tier: .quarterCentury)
}

#Preview("Tier 7 - Centurion") {
  AchievementBadgeView(tier: .centurion)
}
```

- [ ] **Step 2: Build to verify it compiles**

Run: `xcodebuild -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Open the previews and confirm the badge visibly gains a ring per tier**

In Xcode, open `AchievementBadgeView.swift` and check the canvas for all four named previews — "Locked" shows a dim outline star with no rings, "Tier 1" shows one ring, "Tier 4" shows four rings, "Tier 7" shows seven rings, all in the app's Gold accent color except Locked.

- [ ] **Step 4: Commit**

```bash
git add MedalWall/Features/Profile/Profile/Views/AchievementBadgeView.swift
git commit -m "feat: add evolving AchievementBadgeView"
```

---

### Task 8: Rewrite `ProfileAchievementRow` and `ProfileAchievementsSection`

**Files:**
- Modify: `MedalWall/Features/Profile/Profile/Views/ProfileAchievementRow.swift`
- Modify: `MedalWall/Features/Profile/Profile/Views/ProfileAchievementsSection.swift`

**Interfaces:**
- Consumes: `AchievementBadgeView` (Task 7), `AchievementProgress` (Task 2).
- Produces: `struct ProfileAchievementRow: View` with `let trackName: String`, `let progress: AchievementProgress`; `struct ProfileAchievementsSection: View` with `let fullMarathonProgress: AchievementProgress`, `let halfMarathonProgress: AchievementProgress`.

No new test: SwiftUI views in this codebase have no unit tests, only `#Preview`s (see Task 7 rationale).

- [ ] **Step 1: Rewrite `ProfileAchievementRow`**

Replace the full contents of `MedalWall/Features/Profile/Profile/Views/ProfileAchievementRow.swift`:

```swift
//
//  ProfileAchievementRow.swift
//  MedalWall
//
//  Created by Quien on 2026-03-06.
//

import SwiftUI

struct ProfileAchievementRow: View {
  let trackName: String
  let progress: AchievementProgress

  var body: some View {
    HStack {
      AchievementBadgeView(tier: progress.unlockedTier)

      VStack(alignment: .leading) {
        Text(trackName)
          .font(.headline)
          .fontWeight(.bold)

        Text(progress.unlockedTier?.name ?? "Not started")
          .font(.footnote)
          .foregroundStyle(Color.Text.tertiary)

        if let nextTier = progress.nextTier {
          ProgressView(value: Double(progress.currentCount), total: Double(nextTier.threshold))

          Text("\(progress.currentCount) of \(nextTier.threshold) \u{2192} \(nextTier.name)")
            .font(.caption)
            .foregroundStyle(Color.Text.tertiary)
        }
      }  // VStack

      Spacer()
    }  // HStack
    .frame(maxWidth: .infinity)
    .surfaceStyle()
  }
}

#Preview("Locked") {
  ProfileAchievementRow(
    trackName: "Full Marathon",
    progress: AchievementProgress.compute(persistedMilestone: 0, liveCount: 0)
  )
}

#Preview("In progress") {
  ProfileAchievementRow(
    trackName: "Half Marathon",
    progress: AchievementProgress.compute(persistedMilestone: 5, liveCount: 7)
  )
}

#Preview("Maxed") {
  ProfileAchievementRow(
    trackName: "Full Marathon",
    progress: AchievementProgress.compute(persistedMilestone: 100, liveCount: 100)
  )
}
```

- [ ] **Step 2: Rewrite `ProfileAchievementsSection`**

Replace the full contents of `MedalWall/Features/Profile/Profile/Views/ProfileAchievementsSection.swift`:

```swift
//
//  ProfileAchievementsSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-05.
//

import SwiftUI

struct ProfileAchievementsSection: View {
  let fullMarathonProgress: AchievementProgress
  let halfMarathonProgress: AchievementProgress

  var body: some View {
    SectionContainer(title: "achievements") {
      VStack(spacing: 15) {
        ProfileAchievementRow(trackName: "Full Marathon", progress: fullMarathonProgress)

        ProfileAchievementRow(trackName: "Half Marathon", progress: halfMarathonProgress)
      }
    }
  }
}

#Preview {
  ProfileAchievementsSection(
    fullMarathonProgress: AchievementProgress.compute(persistedMilestone: 10, liveCount: 10),
    halfMarathonProgress: AchievementProgress.compute(persistedMilestone: 0, liveCount: 2)
  )
}
```

- [ ] **Step 3: Build to verify it compiles**

Run: `xcodebuild -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
Expected: BUILD SUCCEEDED.

- [ ] **Step 4: Open the previews and confirm all three `ProfileAchievementRow` states and the combined section render correctly**

In Xcode, check "Locked", "In progress" (shows a progress bar and "7 of 10 → Perfect Ten"), and "Maxed" (no progress bar, shows "Centurion") previews for `ProfileAchievementRow`, and the default preview for `ProfileAchievementsSection` showing both tracks stacked.

- [ ] **Step 5: Commit**

```bash
git add MedalWall/Features/Profile/Profile/Views/ProfileAchievementRow.swift MedalWall/Features/Profile/Profile/Views/ProfileAchievementsSection.swift
git commit -m "feat: render real achievement progress in ProfileAchievementRow/Section"
```

---

### Task 9: Wire `ProfileAchievementsSection` into `ProfileView`

**Files:**
- Modify: `MedalWall/Features/Profile/Profile/Views/ProfileView.swift`

**Interfaces:**
- Consumes: `ProfileAchievementsSection` (Task 8), `ProfileViewModel.fullMarathonProgress(user:)` / `halfMarathonProgress(user:)` (Task 6), `UserManager.currentUser` (existing).

No new test: `ProfileView` has no existing test file; this is a pure view-composition change.

- [ ] **Step 1: Add the section to the scroll view**

In `MedalWall/Features/Profile/Profile/Views/ProfileView.swift`, insert `ProfileAchievementsSection` between `ProfileSummarySection` and the closing `.padding(.bottom, 10)`:

```swift
        ProfileSummarySection(
          totalMedals: viewModel.totalMedals,
          fullCount: viewModel.fullCount,
          halfCount: viewModel.halfCount,
          bestFullTime: viewModel.bestFullTime,
          bestHalfTime: viewModel.bestHalfTime
        )

        ProfileAchievementsSection(
          fullMarathonProgress: viewModel.fullMarathonProgress(user: userManager.currentUser),
          halfMarathonProgress: viewModel.halfMarathonProgress(user: userManager.currentUser)
        )

        .padding(.bottom, 10)
```

- [ ] **Step 2: Build to verify it compiles**

Run: `xcodebuild -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro' build`
Expected: BUILD SUCCEEDED.

- [ ] **Step 3: Run the app in the simulator and confirm the achievements section renders on Profile**

Launch the app (signed in with at least one Full or Half Marathon medal logged), navigate to the Profile tab, and confirm the "achievements" section appears below the medal stats grid showing both tracks with real progress.

- [ ] **Step 4: Run the full test suite to verify no regressions**

Run: `xcodebuild test -project MedalWall.xcodeproj -scheme MedalWall -destination 'platform=iOS Simulator,name=iPhone 17 Pro'`
Expected: PASS (all tests, including the new `AchievementTierTests` and `AchievementProgressTests`).

- [ ] **Step 5: Commit**

```bash
git add MedalWall/Features/Profile/Profile/Views/ProfileView.swift
git commit -m "feat: wire ProfileAchievementsSection into ProfileView"
```
