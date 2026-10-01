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

  @Test("a failed editions load surfaces raceFetchFailed")
  func testFailedEditionsLoadSurfacesError() async {
    let race = makeRace()
    let repository = StubRaceRepository(
      races: [race], fetchOutcome: .failure(.raceFetchFailed("network down")))
    let viewModel = EditRaceViewModel(mode: .edit, race: race, repository: repository)

    await viewModel.loadEditions()

    if case .raceFetchFailed = viewModel.error {
    } else {
      Issue.record("expected raceFetchFailed, got \(String(describing: viewModel.error))")
    }
  }

  @Test("an edition added before the editions finish loading is kept")
  func testEditionStagedDuringLoadIsKept() async throws {
    let race = makeRace()
    let raceDay = try #require(
      Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))
    )
    let existing = RaceEdition(
      id: "edition-2025", raceId: race.id, year: 2025, startDate: raceDay,
      endDate: raceDay, createdBy: "uid")
    let repository = StubRaceRepository(races: [race], editions: [race.id: [existing]])
    let viewModel = EditRaceViewModel(mode: .edit, race: race, repository: repository)
    let added = DraftRaceEdition(
      year: 2026, isOneDay: true, startDate: raceDay, endDate: raceDay, distances: [],
      createdBy: "uid")
    viewModel.stageAddEdition(added)

    await viewModel.loadEditions()

    #expect(Set(viewModel.displayedEditions.map(\.id)) == [existing.id, added.id])
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

  // MARK: - Retrying a partly failed save
  private let raceDay = Date(timeIntervalSince1970: 1_577_836_800)

  private func makeExistingEdition() -> RaceEdition {
    RaceEdition(
      id: "edition-2019", raceId: "race-taipei", year: 2019, startDate: raceDay,
      endDate: raceDay, createdBy: "uid")
  }

  private func makeAddedEdition() -> DraftRaceEdition {
    DraftRaceEdition(
      year: 2020, isOneDay: true, startDate: raceDay, endDate: raceDay, distances: [],
      createdBy: "uid")
  }

  @Test("retrying a save after a failed delete does not create an edition twice")
  func testRetryDoesNotRecreateEdition() async {
    let race = makeRace(editionCount: 1)
    let existing = makeExistingEdition()
    let added = makeAddedEdition()
    let repository = StubRaceRepository(
      races: [race], editions: [race.id: [existing]],
      deleteOutcome: .failure(.editionDeleteFailed))
    let viewModel = EditRaceViewModel(mode: .edit, race: race, repository: repository)
    await viewModel.loadEditions()
    viewModel.stageAddEdition(added)
    viewModel.stageDeleteEdition(id: existing.id)

    await viewModel.save(by: "uid")
    viewModel.error = nil  // what dismissing the error sheet does
    await viewModel.save(by: "uid")

    #expect(viewModel.error == .editionSaveFailed)
    #expect(await repository.createdEditions.map(\.id) == [added.id])
    #expect(await repository.races.first?.editionCount == 2)
  }

  @Test("retrying a save after a failed create does not delete an edition twice")
  func testRetryDoesNotRedeleteEdition() async {
    let race = makeRace(editionCount: 1)
    let existing = makeExistingEdition()
    let added = makeAddedEdition()
    let repository = StubRaceRepository(
      races: [race], editions: [race.id: [existing]], failingEditionCreateIDs: [added.id])
    let viewModel = EditRaceViewModel(mode: .edit, race: race, repository: repository)
    await viewModel.loadEditions()
    viewModel.stageAddEdition(added)
    viewModel.stageDeleteEdition(id: existing.id)

    await viewModel.save(by: "uid")
    viewModel.error = nil  // what dismissing the error sheet does
    await viewModel.save(by: "uid")

    #expect(viewModel.error == .editionSaveFailed)
    #expect(await repository.deletedEditionIDs == [existing.id])
    #expect(await repository.races.first?.editionCount == 0)
  }
}
