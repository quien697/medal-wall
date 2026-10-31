//
//  ProfileViewModelRepositoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-29.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct ProfileViewModelRepositoryTests {

  private func makeMedal(id: String) -> Medal {
    Medal(
      id: id,
      name: "Taipei Marathon",
      date: Date(timeIntervalSince1970: 1_577_836_800),
      bibNumber: "00001",
      place: Place(countryCode: "TW", city: "Taipei City"),
      raceEvent: .default,
      userID: "uid"
    )
  }

  @Test("medals load through the injected repository")
  func testLoadMedals() async {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a"), makeMedal(id: "b")])
    let viewModel = ProfileViewModel(repository: repository)

    await viewModel.loadMedals(userId: "uid")

    #expect(viewModel.totalMedals == 2)
    #expect(viewModel.error == nil)
  }

  @Test("a failed fetch surfaces medalFetchFailed")
  func testFailedFetchSurfacesError() async {
    let repository = StubMedalRepository(fetchOutcome: .failure(.medalFetchFailed("network down")))
    let viewModel = ProfileViewModel(repository: repository)

    await viewModel.loadMedals(userId: "uid")

    if case .medalFetchFailed = viewModel.error {
    } else {
      Issue.record("expected medalFetchFailed, got \(String(describing: viewModel.error))")
    }
  }

  @Test("a failed reload keeps the medals already shown")
  func testFailedReloadKeepsMedals() async {
    let repository = StubMedalRepository(fetchOutcome: .failure(.medalFetchFailed("network down")))
    let viewModel = ProfileViewModel(repository: repository)
    viewModel.medals = [makeMedal(id: "a")]

    await viewModel.loadMedals(userId: "uid")

    #expect(viewModel.totalMedals == 1)
  }

  // MARK: - First load vs reload
  @Test("before the first load the statistics are not yet known, so bones show")
  func testSkeletonBeforeFirstLoad() {
    let viewModel = ProfileViewModel(repository: StubMedalRepository())

    #expect(viewModel.isShowingSkeleton)
  }

  @Test("bones show while the first load runs", .timeLimit(.minutes(1)))
  func testSkeletonDuringFirstLoad() async {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a")])
    await repository.fetchHold.holdNext()
    let viewModel = ProfileViewModel(repository: repository)

    let load = Task { await viewModel.loadMedals(userId: "uid") }
    await repository.fetchHold.waitForStart()

    #expect(viewModel.isShowingSkeleton)
    await repository.fetchHold.release()
    await load.value
  }

  @Test("the statistics replace the bones once the medals load")
  func testNoSkeletonAfterLoad() async {
    let viewModel = ProfileViewModel(repository: StubMedalRepository(medals: [makeMedal(id: "a")]))

    await viewModel.loadMedals(userId: "uid")

    #expect(!viewModel.isShowingSkeleton)
    #expect(!viewModel.isLoading)
  }

  @Test("a failed first load shows zero statistics, not bones")
  func testNoSkeletonAfterFailedFirstLoad() async {
    let repository = StubMedalRepository(fetchOutcome: .failure(.medalFetchFailed("offline")))
    let viewModel = ProfileViewModel(repository: repository)

    await viewModel.loadMedals(userId: "uid")

    #expect(!viewModel.isShowingSkeleton)
    #expect(viewModel.totalMedals == 0)
  }

  @Test("a reload keeps the statistics on screen, with no bones", .timeLimit(.minutes(1)))
  func testNoSkeletonDuringReload() async {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a")])
    let viewModel = ProfileViewModel(repository: repository)
    await viewModel.loadMedals(userId: "uid")
    await repository.fetchHold.holdNext()

    let reload = Task { await viewModel.loadMedals(userId: "uid") }
    await repository.fetchHold.waitForStart()

    #expect(!viewModel.isShowingSkeleton)
    #expect(viewModel.totalMedals == 1)
    await repository.fetchHold.release()
    await reload.value
  }

  @Test("a retry after a failed first load shows bones again", .timeLimit(.minutes(1)))
  func testSkeletonDuringRetryAfterFailure() async {
    let repository = StubMedalRepository(
      medals: [makeMedal(id: "a")], fetchOutcome: .failure(.medalFetchFailed("offline")))
    let viewModel = ProfileViewModel(repository: repository)
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

  @Test("a failed reload keeps the statistics on screen, with no bones")
  func testNoSkeletonAfterFailedReload() async {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a"), makeMedal(id: "b")])
    let viewModel = ProfileViewModel(repository: repository)
    await viewModel.loadMedals(userId: "uid")
    await repository.setFetchOutcome(.failure(.medalFetchFailed("offline")))

    await viewModel.loadMedals(userId: "uid")

    #expect(viewModel.totalMedals == 2)
    #expect(!viewModel.isShowingSkeleton)
    #expect(viewModel.error != nil)
  }

  // MARK: - Displayed statistics
  @Test("before the first load the statistics come from placeholder medals, as bones")
  func testStatisticsFromPlaceholdersBeforeLoad() {
    let viewModel = ProfileViewModel(repository: StubMedalRepository())

    #expect(viewModel.totalMedals == Medal.placeholders.count)
    #expect(viewModel.fullCount == Medal.placeholders.fullCount)
    #expect(viewModel.halfCount == Medal.placeholders.halfCount)
    #expect(viewModel.bestFullTime == Medal.placeholders.bestFullTime?.formattedHMS)
    #expect(viewModel.bestHalfTime == Medal.placeholders.bestHalfTime?.formattedHMS)
    #expect(viewModel.fullMarathonProgress == .compute(liveCount: Medal.placeholders.fullCount))
  }

  // MARK: - Late loads
  @Test("a load that lands after a newer one leaves the newer medals", .timeLimit(.minutes(1)))
  func testStaleLoadLeavesNewerMedals() async throws {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a"), makeMedal(id: "b")])
    let viewModel = ProfileViewModel(repository: repository)
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
    let viewModel = ProfileViewModel(repository: repository)
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
    "a load that finishes before a newer one shows its result and leaves the tab loading",
    .timeLimit(.minutes(1)))
  func testOlderLoadFinishingFirstShowsItsResult() async throws {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a")])
    let viewModel = ProfileViewModel(repository: repository)
    await repository.fetchHold.holdNext()
    let olderLoad = Task { await viewModel.loadMedals(userId: "uid") }
    await repository.fetchHold.waitForStart()
    try await repository.createMedal(makeMedal(id: "b"))
    await repository.fetchHold.holdNext()
    let newerLoad = Task { await viewModel.loadMedals(userId: "uid") }
    await repository.fetchHold.waitForStart()

    await repository.fetchHold.release()
    await olderLoad.value

    #expect(viewModel.medals.map(\.id) == ["a"])
    #expect(viewModel.isLoading)
    await repository.fetchHold.release()
    await newerLoad.value
    #expect(viewModel.medals.map(\.id) == ["a", "b"])
    #expect(!viewModel.isLoading)
  }

  @Test(
    "a newer load that fails after an older one loaded keeps the older medals",
    .timeLimit(.minutes(1)))
  func testNewerFailureKeepsOlderMedals() async {
    let repository = StubMedalRepository(medals: [makeMedal(id: "a")])
    let viewModel = ProfileViewModel(repository: repository)
    await repository.fetchHold.holdNext()
    let olderLoad = Task { await viewModel.loadMedals(userId: "uid") }
    await repository.fetchHold.waitForStart()
    await repository.fetchHold.holdNext()
    let newerLoad = Task { await viewModel.loadMedals(userId: "uid") }
    await repository.fetchHold.waitForStart()

    await repository.fetchHold.release()
    await olderLoad.value
    await repository.setFetchOutcome(.failure(.medalFetchFailed("offline")))
    await repository.fetchHold.release()
    await newerLoad.value

    #expect(viewModel.medals.map(\.id) == ["a"])
    #expect(viewModel.error != nil)
    #expect(!viewModel.isLoading)
  }
}
