//
//  RaceDetailViewModelRepositoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-22.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct RaceDetailViewModelRepositoryTests {

  private let raceId = "race-taipei"

  private func makeRace(editionCount: Int = 2) -> Race {
    Race(
      id: raceId,
      name: "Taipei Marathon",
      place: Place(countryCode: "TW", city: "Taipei City"),
      editionCount: editionCount,
      createdBy: "uid"
    )
  }

  private func makeEdition(id: String) -> RaceEdition {
    RaceEdition(
      id: id,
      raceId: raceId,
      year: 2019,
      startDate: Date(timeIntervalSince1970: 1_577_836_800),
      endDate: Date(timeIntervalSince1970: 1_577_836_800),
      createdBy: "uid"
    )
  }

  @Test("editions load newest first")
  func testEditionsLoadNewestFirst() async {
    var older = makeEdition(id: "2019")
    older.startDate = Date(timeIntervalSince1970: 1_546_300_800)  // 2019-01-01
    var newer = makeEdition(id: "2025")
    newer.startDate = Date(timeIntervalSince1970: 1_735_689_600)  // 2025-01-01
    let repository = StubRaceRepository(
      races: [makeRace()], editions: [raceId: [older, newer]])
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)

    await viewModel.loadEditions()

    #expect(viewModel.editions.map(\.id) == ["2025", "2019"])
  }

  @Test("deleting a race removes it and every one of its editions")
  func testDeleteRemovesRaceAndEditions() async {
    let repository = StubRaceRepository(
      races: [makeRace()],
      editions: [raceId: [makeEdition(id: "a"), makeEdition(id: "b")]]
    )
    let viewModel = RaceDetailViewModel(
      race: makeRace(), repository: repository, networkMonitor: StubNetworkMonitor())

    await viewModel.deleteRace()

    #expect(viewModel.error == nil)
    #expect(await repository.races.isEmpty)
    #expect(await repository.editions[raceId] == nil)
  }

  @Test("a failed delete leaves the race and its editions in place")
  func testFailedDeleteKeepsEverything() async {
    let repository = StubRaceRepository(
      races: [makeRace()],
      editions: [raceId: [makeEdition(id: "a"), makeEdition(id: "b")]],
      deleteOutcome: .failure(.raceDeleteFailed)
    )
    let viewModel = RaceDetailViewModel(
      race: makeRace(), repository: repository, networkMonitor: StubNetworkMonitor())

    await viewModel.deleteRace()

    #expect(viewModel.error == .raceDeleteFailed)
    #expect(await repository.races.count == 1)
    #expect(await repository.editions[raceId]?.count == 2)
  }

  @Test("a failed edition fetch surfaces raceFetchFailed")
  func testFailedEditionFetchSurfacesError() async {
    let repository = StubRaceRepository(
      races: [makeRace()], fetchOutcome: .failure(.raceFetchFailed("offline")))
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)

    await viewModel.loadEditions()

    #expect(viewModel.editions.isEmpty)
    if case .raceFetchFailed = viewModel.error {
    } else {
      Issue.record("expected raceFetchFailed, got \(String(describing: viewModel.error))")
    }
  }

  // MARK: - Photos
  /// A race with a logo, one edition with a logo and one without.
  private func makeRepositoryWithLogos(deleteOutcome: Result<Void, AppError> = .success(()))
    -> (Race, StubRaceRepository)
  {
    var race = makeRace()
    race.photoUrl = "https://example.com/logo.jpg"
    var withLogo = makeEdition(id: "a")
    withLogo.photoUrl = "https://example.com/edition.jpg"
    let repository = StubRaceRepository(
      races: [race], editions: [raceId: [withLogo, makeEdition(id: "b")]],
      deleteOutcome: deleteOutcome)
    return (race, repository)
  }

  @Test("a deleted race's logos are deleted from Storage once the race is deleted")
  func testDeletedRaceLogosDeletedAfterDelete() async {
    let (race, repository) = makeRepositoryWithLogos()
    let storage = StubPhotoStorage()
    let viewModel = RaceDetailViewModel(
      race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())

    await viewModel.deleteRace()

    #expect(
      await storage.deletedURLs == [
        "https://example.com/logo.jpg", "https://example.com/edition.jpg"
      ])
  }

  @Test("a race's logos stay in Storage when the race fails to delete")
  func testRaceLogosKeptWhenDeleteFails() async {
    let (race, repository) = makeRepositoryWithLogos(deleteOutcome: .failure(.raceDeleteFailed))
    let storage = StubPhotoStorage()
    let viewModel = RaceDetailViewModel(
      race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())

    await viewModel.deleteRace()

    #expect(await storage.deletedURLs.isEmpty)
  }

  // MARK: - Offline
  @Test("deleting a race offline is refused before anything is deleted")
  func testOfflineDeleteIsRefused() async {
    let (race, repository) = makeRepositoryWithLogos()
    let storage = StubPhotoStorage()
    let networkMonitor = StubNetworkMonitor()
    networkMonitor.isConnectedNow = false
    let viewModel = RaceDetailViewModel(
      race: race, repository: repository, storageService: storage,
      networkMonitor: networkMonitor)

    await viewModel.deleteRace()

    #expect(viewModel.error == .noInternetConnection)
    #expect(await repository.deletedRaceIDs.isEmpty)
    #expect(await storage.deletedURLs.isEmpty)
  }

  // MARK: - First load vs reload
  @Test("before the first load the editions are not yet known to be empty, so bones show")
  func testSkeletonBeforeFirstLoad() {
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: StubRaceRepository())

    #expect(viewModel.isShowingSkeleton)
  }

  @Test("bones show while the first load runs", .timeLimit(.minutes(1)))
  func testSkeletonDuringFirstLoad() async {
    let repository = StubRaceRepository(
      races: [makeRace()], editions: [raceId: [makeEdition(id: "a")]])
    await repository.fetchHold.holdNext()
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)

    let load = Task { await viewModel.loadEditions() }
    await repository.fetchHold.waitForStart()

    #expect(viewModel.isShowingSkeleton)
    await repository.fetchHold.release()
    await load.value
  }

  @Test("the editions replace the bones once they load")
  func testNoSkeletonAfterLoad() async {
    let repository = StubRaceRepository(
      races: [makeRace()], editions: [raceId: [makeEdition(id: "a")]])
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)

    await viewModel.loadEditions()

    #expect(!viewModel.isShowingSkeleton)
  }

  @Test("a failed first load gives way to the empty editions, not bones")
  func testNoSkeletonAfterFailedFirstLoad() async {
    let repository = StubRaceRepository(fetchOutcome: .failure(.raceFetchFailed("offline")))
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)

    await viewModel.loadEditions()

    #expect(!viewModel.isShowingSkeleton)
    #expect(viewModel.editions.isEmpty)
  }

  @Test("a reload keeps the editions on screen, with no bones", .timeLimit(.minutes(1)))
  func testNoSkeletonDuringReload() async {
    let repository = StubRaceRepository(
      races: [makeRace()], editions: [raceId: [makeEdition(id: "a")]])
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)
    await viewModel.loadEditions()
    await repository.fetchHold.holdNext()

    let reload = Task { await viewModel.loadEditions() }
    await repository.fetchHold.waitForStart()

    #expect(!viewModel.isShowingSkeleton)
    #expect(viewModel.editions.count == 1)
    await repository.fetchHold.release()
    await reload.value
  }

  @Test("a retry after a failed first load shows bones again", .timeLimit(.minutes(1)))
  func testSkeletonDuringRetryAfterFailure() async {
    let repository = StubRaceRepository(
      races: [makeRace()], editions: [raceId: [makeEdition(id: "a")]],
      fetchOutcome: .failure(.raceFetchFailed("offline")))
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)
    await viewModel.loadEditions()
    await repository.setFetchOutcome(.success(()))
    await repository.fetchHold.holdNext()

    let retry = Task { await viewModel.loadEditions() }
    await repository.fetchHold.waitForStart()

    #expect(viewModel.isShowingSkeleton)
    await repository.fetchHold.release()
    await retry.value
    #expect(!viewModel.isShowingSkeleton)
  }

  @Test("a failed reload keeps the editions on screen")
  func testFailedReloadKeepsEditions() async {
    let repository = StubRaceRepository(
      races: [makeRace()], editions: [raceId: [makeEdition(id: "a"), makeEdition(id: "b")]])
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)
    await viewModel.loadEditions()
    await repository.setFetchOutcome(.failure(.raceFetchFailed("offline")))

    await viewModel.loadEditions()

    #expect(viewModel.editions.count == 2)
    #expect(!viewModel.isShowingSkeleton)
    #expect(viewModel.error != nil)
  }

  // MARK: - Displayed editions
  @Test("before the first load the section shows placeholder editions, as bones")
  func testDisplayedEditionsArePlaceholdersBeforeLoad() {
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: StubRaceRepository())

    #expect(viewModel.displayedEditions.map(\.id) == RaceEdition.placeholders.map(\.id))
  }

  @Test("once loaded the section shows the race's editions")
  func testDisplayedEditionsAfterLoad() async {
    let repository = StubRaceRepository(
      races: [makeRace()], editions: [raceId: [makeEdition(id: "a")]])
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)

    await viewModel.loadEditions()

    #expect(viewModel.displayedEditions.map(\.id) == ["a"])
  }

  @Test("a failed first load shows no editions, so the empty state shows")
  func testNoDisplayedEditionsAfterFailedFirstLoad() async {
    let repository = StubRaceRepository(fetchOutcome: .failure(.raceFetchFailed("offline")))
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)

    await viewModel.loadEditions()

    #expect(viewModel.displayedEditions.isEmpty)
  }

  // MARK: - Late loads
  @Test("a load that lands after a newer one leaves the newer editions", .timeLimit(.minutes(1)))
  func testStaleLoadLeavesNewerEditions() async throws {
    let repository = StubRaceRepository(
      races: [makeRace()], editions: [raceId: [makeEdition(id: "a"), makeEdition(id: "b")]])
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)
    await repository.fetchHold.holdNext()
    let olderLoad = Task { await viewModel.loadEditions() }
    await repository.fetchHold.waitForStart()
    try await repository.deleteEdition(raceId: raceId, editionId: "b")

    await viewModel.loadEditions()
    await repository.fetchHold.release()
    await olderLoad.value

    #expect(viewModel.editions.map(\.id) == ["a"])
  }

  @Test("a load that fails after a newer one succeeded sets no error", .timeLimit(.minutes(1)))
  func testStaleLoadFailureSetsNoError() async {
    let repository = StubRaceRepository(
      races: [makeRace()], editions: [raceId: [makeEdition(id: "a")]])
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)
    await repository.fetchHold.holdNext()
    let olderLoad = Task { await viewModel.loadEditions() }
    await repository.fetchHold.waitForStart()

    await viewModel.loadEditions()
    await repository.setFetchOutcome(.failure(.raceFetchFailed("offline")))
    await repository.fetchHold.release()
    await olderLoad.value

    #expect(viewModel.error == nil)
    #expect(viewModel.editions.map(\.id) == ["a"])
  }

  @Test(
    "a load that finishes before a newer one changes nothing and leaves the editions loading",
    .timeLimit(.minutes(1)))
  func testStaleLoadFinishingFirstKeepsLoading() async throws {
    let repository = StubRaceRepository(
      races: [makeRace()], editions: [raceId: [makeEdition(id: "a")]])
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)
    await repository.fetchHold.holdNext()
    let olderLoad = Task { await viewModel.loadEditions() }
    await repository.fetchHold.waitForStart()
    try await repository.createEdition(makeEdition(id: "b"))
    await repository.fetchHold.holdNext()
    let newerLoad = Task { await viewModel.loadEditions() }
    await repository.fetchHold.waitForStart()

    await repository.fetchHold.release()
    await olderLoad.value

    #expect(viewModel.editions.isEmpty)
    #expect(viewModel.isShowingSkeleton)
    await repository.fetchHold.release()
    await newerLoad.value
    #expect(Set(viewModel.editions.map(\.id)) == ["a", "b"])
    #expect(!viewModel.isLoading)
  }

  @Test(
    "a reload of the race that lands after a newer one leaves the newer race",
    .timeLimit(.minutes(1)))
  func testStaleRaceReloadLeavesNewerRace() async throws {
    let repository = StubRaceRepository(races: [makeRace()])
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)
    var firstEdit = makeRace()
    firstEdit.name = "Taipei Marathon 2025"
    try await repository.updateRace(firstEdit)
    await repository.fetchHold.holdNext()
    let olderReload = Task { await viewModel.loadRace() }
    await repository.fetchHold.waitForStart()
    var secondEdit = makeRace()
    secondEdit.name = "Taipei City Marathon"
    try await repository.updateRace(secondEdit)

    await viewModel.loadRace()
    await repository.fetchHold.release()
    await olderReload.value

    #expect(viewModel.race.name == "Taipei City Marathon")
  }
}
