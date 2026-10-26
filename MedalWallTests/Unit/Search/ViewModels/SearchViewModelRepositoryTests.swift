//
//  SearchViewModelRepositoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-25.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct SearchViewModelRepositoryTests {

  private let taipei = Place(countryCode: "TW", city: "Taipei City")

  private func makeMedal(id: String, name: String, userID: String = "uid") -> Medal {
    Medal(
      id: id,
      name: name,
      date: Date(timeIntervalSince1970: 1_577_836_800),
      bibNumber: "1",
      place: taipei,
      raceEvent: .default,
      userID: userID
    )
  }

  private func makeRace(id: String, name: String) -> Race {
    Race(id: id, name: name, place: taipei, createdBy: "uid")
  }

  // MARK: - Loading
  @Test("A load fetches both the user's medals and the races")
  func testLoadFetchesBoth() async {
    let medalRepository = StubMedalRepository(medals: [
      makeMedal(id: "mine", name: "Taipei Marathon"),
      makeMedal(id: "theirs", name: "Taipei Marathon", userID: "other")
    ])
    let raceRepository = StubRaceRepository(races: [makeRace(id: "race", name: "Taipei Marathon")])
    let viewModel = SearchViewModel(
      medalRepository: medalRepository, raceRepository: raceRepository)

    await viewModel.load(userId: "uid")
    viewModel.searchText = "Taipei"

    #expect(viewModel.matchingMedals.map(\.id) == ["mine"])
    #expect(viewModel.matchingRaces.map(\.id) == ["race"])
    #expect(await medalRepository.fetchCallCount == 1)
    #expect(await raceRepository.fetchCallCount == 1)
    #expect(viewModel.error == nil)
  }

  @Test("With no signed-in user the medal fetch is skipped and races still load")
  func testNilUserSkipsMedals() async {
    let medalRepository = StubMedalRepository(medals: [makeMedal(id: "a", name: "Taipei Run")])
    let raceRepository = StubRaceRepository(races: [makeRace(id: "race", name: "Taipei Run")])
    let viewModel = SearchViewModel(
      medalRepository: medalRepository, raceRepository: raceRepository)

    await viewModel.load(userId: nil)
    viewModel.searchText = "Taipei"

    #expect(await medalRepository.fetchCallCount == 0)
    #expect(viewModel.matchingMedals.isEmpty)
    #expect(viewModel.matchingRaces.map(\.id) == ["race"])
  }

  @Test("A reload keeps the previous results until it completes", .timeLimit(.minutes(1)))
  func testReloadKeepsPreviousResultsUntilItCompletes() async throws {
    let raceRepository = StubRaceRepository(races: [makeRace(id: "old", name: "Taipei Run")])
    let viewModel = SearchViewModel(
      medalRepository: StubMedalRepository(), raceRepository: raceRepository)
    await viewModel.load(userId: "uid")
    viewModel.searchText = "Taipei"
    try await raceRepository.createRace(makeRace(id: "new", name: "Taipei Marathon"))
    await raceRepository.fetchHold.holdNext()

    let reload = Task { await viewModel.load(userId: "uid") }
    await raceRepository.fetchHold.waitForStart()

    #expect(viewModel.matchingRaces.map(\.id) == ["old"])
    await raceRepository.fetchHold.release()
    await reload.value
    #expect(viewModel.matchingRaces.map(\.id) == ["new", "old"])
  }

  // MARK: - No results
  @Test("No results shows once both loads finish with nothing matching")
  func testNoResultsAfterBothLoads() async {
    let viewModel = SearchViewModel(
      medalRepository: StubMedalRepository(medals: [makeMedal(id: "a", name: "Taipei Run")]),
      raceRepository: StubRaceRepository(races: [makeRace(id: "race", name: "Taipei Run")]))

    await viewModel.load(userId: "uid")
    viewModel.searchText = "Osaka"

    #expect(viewModel.isShowingNoResults)
  }

  @Test("No results never shows for an empty query")
  func testNoNoResultsForEmptyQuery() async {
    let viewModel = SearchViewModel(
      medalRepository: StubMedalRepository(), raceRepository: StubRaceRepository())

    await viewModel.load(userId: "uid")
    viewModel.searchText = " "

    #expect(!viewModel.isShowingNoResults)
  }

  @Test("No results does not show while something matches")
  func testNoNoResultsWhileSomethingMatches() async {
    let viewModel = SearchViewModel(
      medalRepository: StubMedalRepository(medals: [makeMedal(id: "a", name: "Osaka Run")]),
      raceRepository: StubRaceRepository())

    await viewModel.load(userId: "uid")
    viewModel.searchText = "Osaka"

    #expect(!viewModel.isShowingNoResults)
  }

  @Test("No results does not show before anything has loaded")
  func testNoNoResultsBeforeLoad() {
    let viewModel = SearchViewModel(
      medalRepository: StubMedalRepository(), raceRepository: StubRaceRepository())
    viewModel.searchText = "Osaka"

    #expect(!viewModel.isShowingNoResults)
  }

  @Test("No results waits for the races' first load", .timeLimit(.minutes(1)))
  func testNoResultsWaitsForRacesFirstLoad() async {
    let raceRepository = StubRaceRepository(races: [makeRace(id: "race", name: "Taipei Run")])
    await raceRepository.fetchHold.holdNext()
    let viewModel = SearchViewModel(
      medalRepository: StubMedalRepository(), raceRepository: raceRepository)
    viewModel.searchText = "Osaka"

    let load = Task { await viewModel.load(userId: "uid") }
    await raceRepository.fetchHold.waitForStart()

    #expect(!viewModel.isShowingNoResults)
    await raceRepository.fetchHold.release()
    await load.value
    #expect(viewModel.isShowingNoResults)
  }

  @Test("No results waits for the medals' first load", .timeLimit(.minutes(1)))
  func testNoResultsWaitsForMedalsFirstLoad() async {
    let medalRepository = StubMedalRepository(medals: [makeMedal(id: "a", name: "Taipei Run")])
    await medalRepository.fetchHold.holdNext()
    let viewModel = SearchViewModel(
      medalRepository: medalRepository, raceRepository: StubRaceRepository())
    viewModel.searchText = "Osaka"

    let load = Task { await viewModel.load(userId: "uid") }
    await medalRepository.fetchHold.waitForStart()

    #expect(!viewModel.isShowingNoResults)
    await medalRepository.fetchHold.release()
    await load.value
    #expect(viewModel.isShowingNoResults)
  }

  @Test("A reload does not hide a no-results view already shown", .timeLimit(.minutes(1)))
  func testReloadKeepsNoResults() async {
    let raceRepository = StubRaceRepository(races: [makeRace(id: "race", name: "Taipei Run")])
    let viewModel = SearchViewModel(
      medalRepository: StubMedalRepository(), raceRepository: raceRepository)
    await viewModel.load(userId: "uid")
    viewModel.searchText = "Osaka"
    await raceRepository.fetchHold.holdNext()

    let reload = Task { await viewModel.load(userId: "uid") }
    await raceRepository.fetchHold.waitForStart()

    #expect(viewModel.isShowingNoResults)
    await raceRepository.fetchHold.release()
    await reload.value
  }

  // MARK: - Failures
  @Test("A failed race fetch surfaces raceFetchFailed and medals stay searchable")
  func testFailedRaceFetch() async {
    let viewModel = SearchViewModel(
      medalRepository: StubMedalRepository(medals: [makeMedal(id: "a", name: "Taipei Run")]),
      raceRepository: StubRaceRepository(fetchOutcome: .failure(.raceFetchFailed("offline"))))

    await viewModel.load(userId: "uid")
    viewModel.searchText = "Taipei"

    #expect(viewModel.matchingMedals.map(\.id) == ["a"])
    if case .raceFetchFailed = viewModel.error {
    } else {
      Issue.record("expected raceFetchFailed, got \(String(describing: viewModel.error))")
    }
  }

  @Test("A failed medal fetch surfaces medalFetchFailed and races stay searchable")
  func testFailedMedalFetch() async {
    let viewModel = SearchViewModel(
      medalRepository: StubMedalRepository(fetchOutcome: .failure(.medalFetchFailed("offline"))),
      raceRepository: StubRaceRepository(races: [makeRace(id: "race", name: "Taipei Run")]))

    await viewModel.load(userId: "uid")
    viewModel.searchText = "Taipei"

    #expect(viewModel.matchingRaces.map(\.id) == ["race"])
    if case .medalFetchFailed = viewModel.error {
    } else {
      Issue.record("expected medalFetchFailed, got \(String(describing: viewModel.error))")
    }
  }

  @Test("A failed fetch counts as finished, so no results can show")
  func testFailedFetchCountsAsFinished() async {
    let viewModel = SearchViewModel(
      medalRepository: StubMedalRepository(),
      raceRepository: StubRaceRepository(fetchOutcome: .failure(.raceFetchFailed("offline"))))

    await viewModel.load(userId: "uid")
    viewModel.searchText = "Osaka"

    #expect(viewModel.isShowingNoResults)
  }

  @Test("A failed reload keeps the races that loaded before")
  func testFailedReloadKeepsRaces() async {
    let raceRepository = StubRaceRepository(races: [makeRace(id: "race", name: "Taipei Run")])
    let viewModel = SearchViewModel(
      medalRepository: StubMedalRepository(), raceRepository: raceRepository)
    await viewModel.load(userId: "uid")
    await raceRepository.setFetchOutcome(.failure(.raceFetchFailed("offline")))

    await viewModel.load(userId: "uid")
    viewModel.searchText = "Taipei"

    #expect(viewModel.matchingRaces.map(\.id) == ["race"])
  }
}
