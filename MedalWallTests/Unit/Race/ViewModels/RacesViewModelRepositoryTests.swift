//
//  RacesViewModelRepositoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-22.
//

import Testing

@testable import MedalWall

@MainActor
struct RacesViewModelRepositoryTests {

  private func makeRace(id: String, name: String = "Taipei Marathon", editionCount: Int = 0)
    -> Race
  {
    Race(
      id: id,
      name: name,
      place: Place(countryCode: "TW", city: "Taipei City"),
      editionCount: editionCount,
      createdBy: "uid"
    )
  }

  @Test("races load through the injected repository")
  func testLoadRaces() async {
    let repository = StubRaceRepository(races: [makeRace(id: "a"), makeRace(id: "b")])
    let viewModel = RacesViewModel(repository: repository)

    await viewModel.loadRaces()

    #expect(viewModel.races.count == 2)
    #expect(viewModel.error == nil)
  }

  @Test("a failed fetch surfaces raceFetchFailed")
  func testFailedFetchSurfacesError() async {
    let repository = StubRaceRepository(fetchOutcome: .failure(.raceFetchFailed("offline")))
    let viewModel = RacesViewModel(repository: repository)

    await viewModel.loadRaces()

    #expect(viewModel.races.isEmpty)
    if case .raceFetchFailed = viewModel.error {
    } else {
      Issue.record("expected raceFetchFailed, got \(String(describing: viewModel.error))")
    }
  }

  @Test("a negative stored edition count is presented as zero")
  func testNegativeEditionCountIsClamped() async {
    let repository = StubRaceRepository(races: [makeRace(id: "a", editionCount: -1)])
    let viewModel = RacesViewModel(repository: repository)

    await viewModel.loadRaces()

    #expect(viewModel.sortedRaces.first?.editionCount == 0)
  }

  @Test("a real edition count passes through unchanged")
  func testPositiveEditionCountIsKept() async {
    let repository = StubRaceRepository(races: [makeRace(id: "a", editionCount: 3)])
    let viewModel = RacesViewModel(repository: repository)

    await viewModel.loadRaces()

    #expect(viewModel.sortedRaces.first?.editionCount == 3)
  }

  // MARK: - First load vs reload
  @Test("before the first load the list is not yet known to be empty, so bones show")
  func testSkeletonBeforeFirstLoad() {
    let viewModel = RacesViewModel(repository: StubRaceRepository())

    #expect(viewModel.isShowingSkeleton)
  }

  @Test("bones show while the first load runs", .timeLimit(.minutes(1)))
  func testSkeletonDuringFirstLoad() async {
    let repository = StubRaceRepository(races: [makeRace(id: "a")])
    await repository.fetchHold.holdNext()
    let viewModel = RacesViewModel(repository: repository)

    let load = Task { await viewModel.loadRaces() }
    await repository.fetchHold.waitForStart()

    #expect(viewModel.isShowingSkeleton)
    await repository.fetchHold.release()
    await load.value
  }

  @Test("the races replace the bones once they load")
  func testNoSkeletonAfterLoad() async {
    let viewModel = RacesViewModel(repository: StubRaceRepository(races: [makeRace(id: "a")]))

    await viewModel.loadRaces()

    #expect(!viewModel.isShowingSkeleton)
  }

  @Test("a failed first load gives way to the empty state, not bones")
  func testNoSkeletonAfterFailedFirstLoad() async {
    let repository = StubRaceRepository(fetchOutcome: .failure(.raceFetchFailed("offline")))
    let viewModel = RacesViewModel(repository: repository)

    await viewModel.loadRaces()

    #expect(!viewModel.isShowingSkeleton)
    #expect(viewModel.races.isEmpty)
  }

  @Test("a reload keeps the races on screen, with no bones", .timeLimit(.minutes(1)))
  func testNoSkeletonDuringReload() async {
    let repository = StubRaceRepository(races: [makeRace(id: "a")])
    let viewModel = RacesViewModel(repository: repository)
    await viewModel.loadRaces()
    await repository.fetchHold.holdNext()

    let reload = Task { await viewModel.loadRaces() }
    await repository.fetchHold.waitForStart()

    #expect(!viewModel.isShowingSkeleton)
    #expect(viewModel.races.count == 1)
    await repository.fetchHold.release()
    await reload.value
  }

  @Test("a retry after a failed first load shows bones again", .timeLimit(.minutes(1)))
  func testSkeletonDuringRetryAfterFailure() async {
    let repository = StubRaceRepository(
      races: [makeRace(id: "a")], fetchOutcome: .failure(.raceFetchFailed("offline")))
    let viewModel = RacesViewModel(repository: repository)
    await viewModel.loadRaces()
    await repository.setFetchOutcome(.success(()))
    await repository.fetchHold.holdNext()

    let retry = Task { await viewModel.loadRaces() }
    await repository.fetchHold.waitForStart()

    #expect(viewModel.isShowingSkeleton)
    await repository.fetchHold.release()
    await retry.value
    #expect(!viewModel.isShowingSkeleton)
  }

  @Test("a failed reload keeps the races on screen")
  func testFailedReloadKeepsRaces() async {
    let repository = StubRaceRepository(races: [makeRace(id: "a"), makeRace(id: "b")])
    let viewModel = RacesViewModel(repository: repository)
    await viewModel.loadRaces()
    await repository.setFetchOutcome(.failure(.raceFetchFailed("offline")))

    await viewModel.loadRaces()

    #expect(viewModel.races.count == 2)
    #expect(!viewModel.isShowingSkeleton)
    #expect(viewModel.error != nil)
  }

  // MARK: - Displayed races
  @Test("before the first load the list shows placeholder races, as bones")
  func testDisplayedRacesArePlaceholdersBeforeLoad() {
    let viewModel = RacesViewModel(repository: StubRaceRepository())

    #expect(viewModel.displayedRaces.map(\.id) == Race.placeholders.map(\.id))
  }

  @Test("once loaded the list shows every loaded race, sorted")
  func testDisplayedRacesAreSortedAfterLoad() async {
    let repository = StubRaceRepository(races: [
      makeRace(id: "taipei", name: "Taipei Marathon"),
      makeRace(id: "boston", name: "Boston Marathon")
    ])
    let viewModel = RacesViewModel(repository: repository)

    await viewModel.loadRaces()

    #expect(viewModel.displayedRaces.map(\.id) == ["boston", "taipei"])
  }

  @Test("a failed first load shows no races, so the empty state shows")
  func testNoDisplayedRacesAfterFailedFirstLoad() async {
    let repository = StubRaceRepository(fetchOutcome: .failure(.raceFetchFailed("offline")))
    let viewModel = RacesViewModel(repository: repository)

    await viewModel.loadRaces()

    #expect(viewModel.displayedRaces.isEmpty)
  }

  // MARK: - Late loads
  @Test("a load that lands after a newer one leaves the newer races", .timeLimit(.minutes(1)))
  func testStaleLoadLeavesNewerRaces() async throws {
    let repository = StubRaceRepository(races: [makeRace(id: "a"), makeRace(id: "b")])
    let viewModel = RacesViewModel(repository: repository)
    await repository.fetchHold.holdNext()
    let olderLoad = Task { await viewModel.loadRaces() }
    await repository.fetchHold.waitForStart()
    _ = try await repository.deleteRace(id: "b")

    await viewModel.loadRaces()
    await repository.fetchHold.release()
    await olderLoad.value

    #expect(viewModel.races.map(\.id) == ["a"])
  }

  @Test("a load that fails after a newer one succeeded sets no error", .timeLimit(.minutes(1)))
  func testStaleLoadFailureSetsNoError() async {
    let repository = StubRaceRepository(races: [makeRace(id: "a")])
    let viewModel = RacesViewModel(repository: repository)
    await repository.fetchHold.holdNext()
    let olderLoad = Task { await viewModel.loadRaces() }
    await repository.fetchHold.waitForStart()

    await viewModel.loadRaces()
    await repository.setFetchOutcome(.failure(.raceFetchFailed("offline")))
    await repository.fetchHold.release()
    await olderLoad.value

    #expect(viewModel.error == nil)
    #expect(viewModel.races.map(\.id) == ["a"])
  }

  @Test(
    "a load that finishes before a newer one shows its result and leaves the list loading",
    .timeLimit(.minutes(1)))
  func testOlderLoadFinishingFirstShowsItsResult() async throws {
    let repository = StubRaceRepository(races: [makeRace(id: "a")])
    let viewModel = RacesViewModel(repository: repository)
    await repository.fetchHold.holdNext()
    let olderLoad = Task { await viewModel.loadRaces() }
    await repository.fetchHold.waitForStart()
    try await repository.createRace(makeRace(id: "b"))
    await repository.fetchHold.holdNext()
    let newerLoad = Task { await viewModel.loadRaces() }
    await repository.fetchHold.waitForStart()

    await repository.fetchHold.release()
    await olderLoad.value

    #expect(viewModel.races.map(\.id) == ["a"])
    #expect(viewModel.isLoading)
    await repository.fetchHold.release()
    await newerLoad.value
    #expect(viewModel.races.map(\.id) == ["a", "b"])
    #expect(!viewModel.isLoading)
  }

  @Test(
    "a newer load that fails after an older one loaded keeps the older races",
    .timeLimit(.minutes(1)))
  func testNewerFailureKeepsOlderRaces() async {
    let repository = StubRaceRepository(races: [makeRace(id: "a")])
    let viewModel = RacesViewModel(repository: repository)
    await repository.fetchHold.holdNext()
    let olderLoad = Task { await viewModel.loadRaces() }
    await repository.fetchHold.waitForStart()
    await repository.fetchHold.holdNext()
    let newerLoad = Task { await viewModel.loadRaces() }
    await repository.fetchHold.waitForStart()

    await repository.fetchHold.release()
    await olderLoad.value
    await repository.setFetchOutcome(.failure(.raceFetchFailed("offline")))
    await repository.fetchHold.release()
    await newerLoad.value

    #expect(viewModel.races.map(\.id) == ["a"])
    #expect(viewModel.error != nil)
    #expect(!viewModel.isLoading)
  }
}
