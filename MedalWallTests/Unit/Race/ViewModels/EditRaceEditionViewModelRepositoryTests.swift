//
//  EditRaceEditionViewModelRepositoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-22.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct EditRaceEditionViewModelRepositoryTests {

  private let raceId = "race-taipei"

  private func makeRace(editionCount: Int = 0) -> Race {
    Race(
      id: raceId,
      name: "Taipei Marathon",
      place: Place(countryCode: "TW", city: "Taipei City"),
      editionCount: editionCount,
      createdBy: "uid"
    )
  }

  private func makeEdition(id: String = "edition-2019") -> RaceEdition {
    RaceEdition(
      id: id,
      raceId: raceId,
      year: 2019,
      startDate: Date(timeIntervalSince1970: 1_577_836_800),
      endDate: Date(timeIntervalSince1970: 1_577_836_800),
      createdBy: "uid"
    )
  }

  @Test("a saved edition is created and lifts the race's edition count")
  func testSaveCreatesEdition() async {
    let repository = StubRaceRepository(races: [makeRace()])
    let viewModel = EditRaceEditionViewModel(
      mode: .add, raceId: raceId, edition: nil, repository: repository)

    await viewModel.save(by: "uid")

    #expect(viewModel.error == nil)
    #expect(await repository.createdEditions.count == 1)
    #expect(await repository.races.first?.editionCount == 1)
  }

  @Test("a failed save surfaces editionSaveFailed and writes nothing")
  func testFailedSaveSurfacesError() async {
    let repository = StubRaceRepository(
      races: [makeRace()], writeOutcome: .failure(.editionSaveFailed))
    let viewModel = EditRaceEditionViewModel(
      mode: .add, raceId: raceId, edition: nil, repository: repository)

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .editionSaveFailed)
    #expect(await repository.createdEditions.isEmpty)
    #expect(await repository.races.first?.editionCount == 0)
  }

  @Test("a deleted edition lowers the race's edition count")
  func testDeleteLowersCount() async {
    let edition = makeEdition()
    let repository = StubRaceRepository(
      races: [makeRace(editionCount: 1)], editions: [raceId: [edition]])
    let viewModel = EditRaceEditionViewModel(
      mode: .edit, raceId: raceId, edition: edition, repository: repository)

    await viewModel.deleteEdition()

    #expect(viewModel.error == nil)
    #expect(await repository.deletedEditionIDs == [edition.id])
    #expect(await repository.races.first?.editionCount == 0)
  }

  @Test("a failed delete surfaces editionDeleteFailed and keeps the edition")
  func testFailedDeleteSurfacesError() async {
    let edition = makeEdition()
    let repository = StubRaceRepository(
      races: [makeRace(editionCount: 1)],
      editions: [raceId: [edition]],
      deleteOutcome: .failure(.editionDeleteFailed)
    )
    let viewModel = EditRaceEditionViewModel(
      mode: .edit, raceId: raceId, edition: edition, repository: repository)

    await viewModel.deleteEdition()

    #expect(viewModel.error == .editionDeleteFailed)
    #expect(await repository.editions[raceId]?.count == 1)
    #expect(await repository.races.first?.editionCount == 1)
  }
}
