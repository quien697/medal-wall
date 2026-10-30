//
//  MedalsViewModelRepositoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-22.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct MedalsViewModelRepositoryTests {

  private func makeMedal(id: String, userID: String = "uid") -> Medal {
    Medal(
      id: id,
      name: "Taipei Marathon",
      date: Date(timeIntervalSince1970: 1_577_836_800),
      bibNumber: "00001",
      place: Place(countryCode: "TW", city: "Taipei City"),
      raceEvent: .default,
      userID: userID
    )
  }

  @Test("medals load through the injected repository")
  func testLoadMedals() async {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a"), makeMedal(id: "b")])
    let viewModel = MedalsViewModel(repository: repository)

    await viewModel.loadMedals(userId: "uid")

    #expect(viewModel.medals.count == 2)
    #expect(await repository.fetchCallCount == 1)
    #expect(viewModel.error == nil)
    #expect(viewModel.isLoading == false)
  }

  @Test("only the requesting user's medals load")
  func testLoadMedalsScopedToUser() async {
    let repository = StubMedalRepository(medals: [
      makeMedal(id: "mine"),
      makeMedal(id: "theirs", userID: "other")
    ])
    let viewModel = MedalsViewModel(repository: repository)

    await viewModel.loadMedals(userId: "uid")

    #expect(viewModel.medals.map(\.id) == ["mine"])
  }

  @Test("a failed fetch surfaces medalFetchFailed")
  func testFailedFetchSurfacesError() async {
    let repository = StubMedalRepository(fetchOutcome: .failure(.medalFetchFailed("network down")))
    let viewModel = MedalsViewModel(repository: repository)

    await viewModel.loadMedals(userId: "uid")

    #expect(viewModel.medals.isEmpty)
    #expect(viewModel.isLoading == false)
    if case .medalFetchFailed = viewModel.error {
    } else {
      Issue.record("expected medalFetchFailed, got \(String(describing: viewModel.error))")
    }
  }

  // MARK: - First load vs reload
  @Test("before the first load the collection is not yet known to be empty, so bones show")
  func testSkeletonBeforeFirstLoad() {
    let viewModel = MedalsViewModel(repository: StubMedalRepository())

    #expect(viewModel.isShowingSkeleton)
  }

  @Test("bones show while the first load runs", .timeLimit(.minutes(1)))
  func testSkeletonDuringFirstLoad() async {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a")])
    await repository.fetchHold.holdNext()
    let viewModel = MedalsViewModel(repository: repository)

    let load = Task { await viewModel.loadMedals(userId: "uid") }
    await repository.fetchHold.waitForStart()

    #expect(viewModel.isShowingSkeleton)
    await repository.fetchHold.release()
    await load.value
  }

  @Test("the collection replaces the bones once it loads")
  func testNoSkeletonAfterLoad() async {
    let viewModel = MedalsViewModel(repository: StubMedalRepository(medals: [makeMedal(id: "a")]))

    await viewModel.loadMedals(userId: "uid")

    #expect(!viewModel.isShowingSkeleton)
  }

  @Test("a failed first load gives way to the empty state, not bones")
  func testNoSkeletonAfterFailedFirstLoad() async {
    let repository = StubMedalRepository(fetchOutcome: .failure(.medalFetchFailed("offline")))
    let viewModel = MedalsViewModel(repository: repository)

    await viewModel.loadMedals(userId: "uid")

    #expect(!viewModel.isShowingSkeleton)
    #expect(viewModel.isEmpty)
  }

  @Test("a reload keeps the collection on screen, with no bones", .timeLimit(.minutes(1)))
  func testNoSkeletonDuringReload() async {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a")])
    let viewModel = MedalsViewModel(repository: repository)
    await viewModel.loadMedals(userId: "uid")
    await repository.fetchHold.holdNext()

    let reload = Task { await viewModel.loadMedals(userId: "uid") }
    await repository.fetchHold.waitForStart()

    #expect(!viewModel.isShowingSkeleton)
    #expect(viewModel.medals.count == 1)
    await repository.fetchHold.release()
    await reload.value
  }

  @Test("a retry after a failed first load shows bones again", .timeLimit(.minutes(1)))
  func testSkeletonDuringRetryAfterFailure() async {
    let repository = StubMedalRepository(
      medals: [makeMedal(id: "a")], fetchOutcome: .failure(.medalFetchFailed("offline")))
    let viewModel = MedalsViewModel(repository: repository)
    await viewModel.loadMedals(userId: "uid")
    await repository.setFetchOutcome(.success(()))
    await repository.fetchHold.holdNext()

    let retry = Task { await viewModel.loadMedals(userId: "uid") }
    await repository.fetchHold.waitForStart()

    #expect(viewModel.isShowingSkeleton)
    await repository.fetchHold.release()
    await retry.value
    #expect(!viewModel.isShowingSkeleton)
  }

  @Test("a failed reload keeps the collection on screen")
  func testFailedReloadKeepsMedals() async {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a"), makeMedal(id: "b")])
    let viewModel = MedalsViewModel(repository: repository)
    await viewModel.loadMedals(userId: "uid")
    await repository.setFetchOutcome(.failure(.medalFetchFailed("offline")))

    await viewModel.loadMedals(userId: "uid")

    #expect(viewModel.medals.count == 2)
    #expect(!viewModel.isShowingSkeleton)
    #expect(viewModel.error != nil)
  }

  // MARK: - Late loads
  @Test("a load that lands after a newer one leaves the newer medals", .timeLimit(.minutes(1)))
  func testStaleLoadLeavesNewerMedals() async throws {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a"), makeMedal(id: "b")])
    let viewModel = MedalsViewModel(repository: repository)
    await repository.fetchHold.holdNext()
    let olderLoad = Task { await viewModel.loadMedals(userId: "uid") }
    await repository.fetchHold.waitForStart()
    try await repository.deleteMedal(id: "b", userId: "uid")

    await viewModel.loadMedals(userId: "uid")
    await repository.fetchHold.release()
    await olderLoad.value

    #expect(viewModel.medals.map(\.id) == ["a"])
  }

  @Test("a load that fails after a newer one succeeded sets no error", .timeLimit(.minutes(1)))
  func testStaleLoadFailureSetsNoError() async {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a")])
    let viewModel = MedalsViewModel(repository: repository)
    await repository.fetchHold.holdNext()
    let olderLoad = Task { await viewModel.loadMedals(userId: "uid") }
    await repository.fetchHold.waitForStart()

    await viewModel.loadMedals(userId: "uid")
    await repository.setFetchOutcome(.failure(.medalFetchFailed("offline")))
    await repository.fetchHold.release()
    await olderLoad.value

    #expect(viewModel.error == nil)
    #expect(viewModel.medals.map(\.id) == ["a"])
  }

  @Test(
    "a load that finishes before a newer one changes nothing and leaves the list loading",
    .timeLimit(.minutes(1)))
  func testStaleLoadFinishingFirstKeepsLoading() async throws {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a")])
    let viewModel = MedalsViewModel(repository: repository)
    await repository.fetchHold.holdNext()
    let olderLoad = Task { await viewModel.loadMedals(userId: "uid") }
    await repository.fetchHold.waitForStart()
    try await repository.createMedal(makeMedal(id: "b"))
    await repository.fetchHold.holdNext()
    let newerLoad = Task { await viewModel.loadMedals(userId: "uid") }
    await repository.fetchHold.waitForStart()

    await repository.fetchHold.release()
    await olderLoad.value

    #expect(viewModel.medals.isEmpty)
    #expect(viewModel.isShowingSkeleton)
    await repository.fetchHold.release()
    await newerLoad.value
    #expect(viewModel.medals.map(\.id) == ["a", "b"])
    #expect(!viewModel.isLoading)
  }
}
