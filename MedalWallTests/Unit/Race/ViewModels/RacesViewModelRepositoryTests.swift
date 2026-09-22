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

    #expect(viewModel.filteredRaces.first?.editionCount == 0)
  }

  @Test("a real edition count passes through unchanged")
  func testPositiveEditionCountIsKept() async {
    let repository = StubRaceRepository(races: [makeRace(id: "a", editionCount: 3)])
    let viewModel = RacesViewModel(repository: repository)

    await viewModel.loadRaces()

    #expect(viewModel.filteredRaces.first?.editionCount == 3)
  }

  @Test("a failed delete surfaces raceDeleteFailed and keeps the race")
  func testFailedDeleteSurfacesError() async {
    let race = makeRace(id: "a")
    let repository = StubRaceRepository(
      races: [race], deleteOutcome: .failure(.raceDeleteFailed))
    let viewModel = RacesViewModel(repository: repository)
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
    let viewModel = RacesViewModel(repository: repository)
    await viewModel.loadRaces()

    await viewModel.deleteRace(race)

    #expect(viewModel.error == nil)
    #expect(viewModel.races.map(\.id) == ["b"])
    #expect(await repository.deletedRaceIDs == ["a"])
  }
}
