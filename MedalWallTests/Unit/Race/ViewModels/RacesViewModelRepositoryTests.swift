//
//  RacesViewModelRepositoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-22.
//

import Foundation
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

  @Test("a failed delete surfaces raceDeleteFailed and keeps the race")
  func testFailedDeleteSurfacesError() async {
    let race = makeRace(id: "a")
    let repository = StubRaceRepository(
      races: [race], deleteOutcome: .failure(.raceDeleteFailed))
    let viewModel = RacesViewModel(repository: repository, networkMonitor: StubNetworkMonitor())
    await viewModel.loadRaces()

    await viewModel.deleteRace(race)

    #expect(viewModel.error == .raceDeleteFailed)
    #expect(viewModel.races.map(\.id) == ["a"])
    #expect(await repository.races.count == 1)
  }

  @Test("a successful delete removes the race locally and in the store")
  func testSuccessfulDelete() async {
    let race = makeRace(id: "a")
    let repository = StubRaceRepository(races: [race, makeRace(id: "b")])
    let viewModel = RacesViewModel(repository: repository, networkMonitor: StubNetworkMonitor())
    await viewModel.loadRaces()

    await viewModel.deleteRace(race)

    #expect(viewModel.error == nil)
    #expect(viewModel.races.map(\.id) == ["b"])
    #expect(await repository.deletedRaceIDs == ["a"])
  }

  // MARK: - Photos
  /// A race with a logo, one edition with a logo and one without.
  private func makeRepositoryWithLogos(deleteOutcome: Result<Void, AppError> = .success(()))
    -> (Race, StubRaceRepository)
  {
    var race = makeRace(id: "a")
    race.photoUrl = "https://example.com/logo.jpg"
    let raceDay = Date(timeIntervalSince1970: 1_577_836_800)
    let withLogo = RaceEdition(
      id: "edition-logo", raceId: race.id, year: 2019, startDate: raceDay, endDate: raceDay,
      photoUrl: "https://example.com/edition.jpg", raceEvents: [], createdBy: "uid")
    let withoutLogo = RaceEdition(
      id: "edition-plain", raceId: race.id, year: 2018, startDate: raceDay, endDate: raceDay,
      createdBy: "uid")
    let repository = StubRaceRepository(
      races: [race], editions: [race.id: [withLogo, withoutLogo]], deleteOutcome: deleteOutcome)
    return (race, repository)
  }

  @Test("a deleted race's logos are deleted from Storage once the race is deleted")
  func testDeletedRaceLogosDeletedAfterDelete() async {
    let (race, repository) = makeRepositoryWithLogos()
    let storage = StubPhotoStorage()
    let viewModel = RacesViewModel(
      repository: repository, storageService: storage, networkMonitor: StubNetworkMonitor())
    await viewModel.loadRaces()

    await viewModel.deleteRace(race)

    #expect(
      await storage.deletedURLs == [
        "https://example.com/logo.jpg", "https://example.com/edition.jpg"
      ])
    #expect(
      await storage.deletedOwners == [
        .race(raceId: "a"), .edition(raceId: "a", editionId: "edition-logo")
      ])
  }

  @Test("a race's logos stay in Storage when the race fails to delete")
  func testRaceLogosKeptWhenDeleteFails() async {
    let (race, repository) = makeRepositoryWithLogos(deleteOutcome: .failure(.raceDeleteFailed))
    let storage = StubPhotoStorage()
    let viewModel = RacesViewModel(
      repository: repository, storageService: storage, networkMonitor: StubNetworkMonitor())
    await viewModel.loadRaces()

    await viewModel.deleteRace(race)

    #expect(await storage.deletedURLs.isEmpty)
  }

  // MARK: - Offline
  @Test("deleting a race offline is refused and the race stays in the list")
  func testOfflineDeleteIsRefused() async {
    let (race, repository) = makeRepositoryWithLogos()
    let storage = StubPhotoStorage()
    let networkMonitor = StubNetworkMonitor()
    networkMonitor.isConnectedNow = false
    let viewModel = RacesViewModel(
      repository: repository, storageService: storage, networkMonitor: networkMonitor)
    await viewModel.loadRaces()

    await viewModel.deleteRace(race)

    #expect(viewModel.error == .noInternetConnection)
    #expect(viewModel.races.map(\.id) == [race.id])
    #expect(await repository.deletedRaceIDs.isEmpty)
    #expect(await storage.deletedURLs.isEmpty)
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

  // MARK: - Delete during reload
  @Test(
    "a race cannot be deleted while the list reloads, whose older data would bring it back",
    .timeLimit(.minutes(1)))
  func testNoDeleteDuringReload() async {
    let repository = StubRaceRepository(races: [makeRace(id: "a")])
    let viewModel = RacesViewModel(repository: repository)
    await viewModel.loadRaces()
    await repository.fetchHold.holdNext()

    let reload = Task { await viewModel.loadRaces() }
    await repository.fetchHold.waitForStart()

    #expect(!viewModel.canDeleteRaces)
    await repository.fetchHold.release()
    await reload.value
  }

  @Test("once the races have loaded they can be deleted")
  func testDeleteAfterLoad() async {
    let viewModel = RacesViewModel(repository: StubRaceRepository(races: [makeRace(id: "a")]))

    await viewModel.loadRaces()

    #expect(viewModel.canDeleteRaces)
  }
}
