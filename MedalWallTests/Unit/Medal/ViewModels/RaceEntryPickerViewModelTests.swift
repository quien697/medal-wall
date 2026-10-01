//
//  RaceEntryPickerViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-30.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct RaceEntryPickerViewModelTests {

  private let race = Race(
    id: "race-taipei",
    name: "Taipei Marathon",
    place: Place(countryCode: "TW", city: "Taipei City"),
    createdBy: "uid"
  )

  private func makeEdition(year: Int) -> RaceEdition {
    RaceEdition(
      id: "edition-\(year)", raceId: race.id, year: year, startDate: Date.startOfYear(year),
      endDate: Date.startOfYear(year), createdBy: "uid")
  }

  @Test("races and their editions load, newest edition first")
  func testLoadSortsEditionsNewestFirst() async {
    let repository = StubRaceRepository(
      races: [race], editions: [race.id: [makeEdition(year: 2019), makeEdition(year: 2025)]])
    let viewModel = RaceEntryPickerViewModel(repository: repository)

    await viewModel.load()

    #expect(viewModel.races.map(\.id) == [race.id])
    #expect(viewModel.editions[race.id]?.map(\.year) == [2025, 2019])
    #expect(viewModel.error == nil)
  }

  @Test("a failed fetch surfaces raceFetchFailed")
  func testFailedFetchSurfacesError() async {
    let repository = StubRaceRepository(
      races: [race], fetchOutcome: .failure(.raceFetchFailed("network down")))
    let viewModel = RaceEntryPickerViewModel(repository: repository)

    await viewModel.load()

    if case .raceFetchFailed = viewModel.error {
    } else {
      Issue.record("expected raceFetchFailed, got \(String(describing: viewModel.error))")
    }
  }

  @Test("one race's editions failing to load still lists the other races and reports it")
  func testFailedEditionsFetchKeepsOtherRaces() async {
    let tokyo = Race(
      id: "race-tokyo",
      name: "Tokyo Marathon",
      place: Place(countryCode: "JP", city: "Tokyo"),
      createdBy: "uid"
    )
    let tokyo2025 = RaceEdition(
      id: "edition-tokyo-2025", raceId: tokyo.id, year: 2025, startDate: Date.startOfYear(2025),
      endDate: Date.startOfYear(2025), createdBy: "uid")
    let repository = StubRaceRepository(
      races: [race, tokyo], editions: [tokyo.id: [tokyo2025]],
      failingEditionRaceIDs: [race.id])
    let viewModel = RaceEntryPickerViewModel(repository: repository)

    await viewModel.load()

    #expect(viewModel.races.map(\.id) == [race.id, tokyo.id])
    #expect(viewModel.editions[tokyo.id]?.map(\.year) == [2025])
    if case .raceFetchFailed = viewModel.error {
    } else {
      Issue.record("expected raceFetchFailed, got \(String(describing: viewModel.error))")
    }
  }

  @Test("the picker counts as loading until its first load finishes")
  func testLoadingUntilFirstLoadFinishes() async {
    let viewModel = RaceEntryPickerViewModel(repository: StubRaceRepository())

    #expect(viewModel.isLoading)

    await viewModel.load()

    #expect(viewModel.isLoading == false)
  }
}
