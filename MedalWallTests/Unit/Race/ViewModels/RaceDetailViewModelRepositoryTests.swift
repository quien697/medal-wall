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
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)

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
    let viewModel = RaceDetailViewModel(race: makeRace(), repository: repository)

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
}
