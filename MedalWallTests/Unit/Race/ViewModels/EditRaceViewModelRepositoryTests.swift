//
//  EditRaceViewModelRepositoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-22.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct EditRaceViewModelRepositoryTests {

  private func makeRace(editionCount: Int = 0) -> Race {
    Race(
      id: "race-taipei",
      name: "Taipei Marathon",
      place: Place(countryCode: "TW", city: "Taipei City"),
      editionCount: editionCount,
      createdBy: "uid"
    )
  }

  @Test("a new race is created through the injected repository")
  func testSaveCreatesRace() async {
    let repository = StubRaceRepository()
    let viewModel = EditRaceViewModel(mode: .add, race: nil, repository: repository)
    viewModel.name = "Vancouver Marathon"
    viewModel.place = Place(countryCode: "CA", city: "Vancouver")

    await viewModel.save(by: "uid")

    #expect(viewModel.error == nil)
    #expect(await repository.createdRaces.count == 1)
    #expect(await repository.createdRaces.first?.name == "Vancouver Marathon")
  }

  @Test("a failed save surfaces raceSaveFailed")
  func testFailedSaveSurfacesError() async {
    let repository = StubRaceRepository(writeOutcome: .failure(.raceSaveFailed))
    let viewModel = EditRaceViewModel(mode: .add, race: nil, repository: repository)
    viewModel.name = "Vancouver Marathon"
    viewModel.place = Place(countryCode: "CA", city: "Vancouver")

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .raceSaveFailed)
    #expect(await repository.createdRaces.isEmpty)
  }

  @Test("editing a race leaves an edition count added elsewhere alone")
  func testEditDoesNotClobberEditionCount() async {
    // The screen opened when the race had one edition; another client has since added two.
    let stale = makeRace(editionCount: 1)
    let repository = StubRaceRepository(races: [makeRace(editionCount: 3)])
    let viewModel = EditRaceViewModel(mode: .edit, race: stale, repository: repository)
    viewModel.name = "Taipei Marathon 2026"
    viewModel.place = stale.place

    await viewModel.save(by: "uid")

    #expect(viewModel.error == nil)
    #expect(await repository.races.first?.name == "Taipei Marathon 2026")
    #expect(await repository.races.first?.editionCount == 3)
  }

  @Test("an added edition edited again before saving is still created")
  func testReEditedNewEditionIsCreated() async throws {
    let race = makeRace()
    let repository = StubRaceRepository(races: [race])
    let viewModel = EditRaceViewModel(mode: .edit, race: race, repository: repository)
    let raceDay = try #require(
      Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))
    )
    let added = DraftRaceEdition(
      year: 2026, isOneDay: true, startDate: raceDay, endDate: raceDay, distances: [],
      createdBy: "uid")
    viewModel.stageAddEdition(added)

    let editor = EditRaceEditionViewModel(
      mode: .edit, raceId: race.id, edition: nil, draft: added)
    editor.updateStartDate(raceDay.addingTimeInterval(86_400))
    viewModel.stageUpdateEdition(editor.buildDraft(userId: "uid"))
    await viewModel.save(by: "uid")

    #expect(viewModel.error == nil)
    #expect(await repository.createdEditions.map(\.id) == [added.id])
  }
}
