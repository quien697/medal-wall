//
//  EditRaceViewModelEditionLimitTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-29.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct EditRaceViewModelEditionLimitTests {

  private let raceDay = Date(timeIntervalSince1970: 1_577_836_800)

  private func makeRace(editionCount: Int) -> Race {
    Race(
      id: "race-taipei",
      name: "Taipei Marathon",
      place: Place(countryCode: "TW", city: "Taipei City"),
      editionCount: editionCount,
      createdBy: "uid"
    )
  }

  private func makeAddedEdition() -> DraftRaceEdition {
    DraftRaceEdition(
      year: 2020, isOneDay: true, startDate: raceDay, endDate: raceDay, distances: [],
      createdBy: "uid")
  }

  /// A view model for a race holding `count` editions, with them loaded.
  private func makeLoadedViewModel(editionCount count: Int) async -> EditRaceViewModel {
    let editions = (0..<count).map { index in
      RaceEdition(
        id: "edition-\(index)", raceId: "race-taipei", year: 1900 + index, startDate: raceDay,
        endDate: raceDay, createdBy: "uid")
    }
    let repository = StubRaceRepository(
      races: [makeRace(editionCount: count)], editions: ["race-taipei": editions])
    let viewModel = EditRaceViewModel(
      mode: .edit, race: makeRace(editionCount: count), repository: repository,
      networkMonitor: StubNetworkMonitor())
    await viewModel.loadEditions()
    return viewModel
  }

  @Test("a race with 199 editions can add another")
  func testCanAddBelowLimit() async {
    let viewModel = await makeLoadedViewModel(editionCount: 199)

    #expect(viewModel.canAddEdition)
  }

  @Test("a race with 200 editions cannot add another")
  func testCannotAddAtLimit() async {
    let viewModel = await makeLoadedViewModel(editionCount: 200)

    #expect(!viewModel.canAddEdition)
  }

  @Test("staging a delete at 200 editions frees a place")
  func testStagedDeleteFreesPlace() async {
    let viewModel = await makeLoadedViewModel(editionCount: 200)

    viewModel.stageDeleteEdition(id: "edition-0")

    #expect(viewModel.canAddEdition)
  }

  @Test("a staged addition counts toward the limit")
  func testStagedAdditionCounts() async {
    let viewModel = await makeLoadedViewModel(editionCount: 199)

    viewModel.stageAddEdition(makeAddedEdition())

    #expect(!viewModel.canAddEdition)
  }

  @Test("before the editions load, a stored count of 200 stops another")
  func testStoredCountAtLimitBeforeLoad() {
    let viewModel = EditRaceViewModel(
      mode: .edit, race: makeRace(editionCount: 200), repository: StubRaceRepository(),
      networkMonitor: StubNetworkMonitor())

    #expect(!viewModel.canAddEdition)
  }

  @Test("before the editions load, a stored count of 199 allows another")
  func testStoredCountBelowLimitBeforeLoad() {
    let viewModel = EditRaceViewModel(
      mode: .edit, race: makeRace(editionCount: 199), repository: StubRaceRepository(),
      networkMonitor: StubNetworkMonitor())

    #expect(viewModel.canAddEdition)
  }

  @Test("before the editions load, a negative stored count counts as none")
  func testNegativeStoredCountBeforeLoad() {
    let viewModel = EditRaceViewModel(
      mode: .edit, race: makeRace(editionCount: -1), repository: StubRaceRepository(),
      networkMonitor: StubNetworkMonitor())

    for _ in 0..<200 {
      viewModel.stageAddEdition(makeAddedEdition())
    }

    #expect(!viewModel.canAddEdition)
  }
}
