//
//  EditRaceViewModelReplacedPhotoTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-09.
//

import Foundation
import Testing
import UIKit

@testable import MedalWall

@MainActor
struct EditRaceViewModelReplacedPhotoTests {

  private let logoUrl = "https://example.com/logo.jpg"
  private let editionPhotoUrl = "https://example.com/edition.jpg"

  private func makeRace() -> Race {
    var race = Race(
      id: "race-taipei",
      name: "Taipei Marathon",
      place: Place(countryCode: "TW", city: "Taipei City"),
      createdBy: "uid"
    )
    race.photoUrl = logoUrl
    return race
  }

  private func makeEdition() throws -> RaceEdition {
    let raceDay = try #require(
      Calendar.current.date(from: DateComponents(year: 2025, month: 12, day: 21))
    )
    return RaceEdition(
      id: "edition-2025", raceId: "race-taipei", year: 2025, startDate: raceDay,
      endDate: raceDay, photoUrl: editionPhotoUrl, distances: [], createdBy: "uid")
  }

  private func makePhotoData() throws -> Data {
    let image = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
      UIColor.red.setFill()
      context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    return try #require(image.pngData())
  }

  @Test("a replaced race logo is deleted from Storage once the race saves")
  func testReplacedLogoDeletedAfterSave() async {
    let race = makeRace()
    let repository = StubRaceRepository(races: [race])
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    viewModel.updatePhoto(with: UIImage())

    await viewModel.save(by: "uid")

    #expect(await storage.deletedURLs == [logoUrl])
    #expect(await storage.deletedOwners == [.race(raceId: "race-taipei")])
  }

  @Test("a replaced race logo stays in Storage and the new upload is deleted when the save fails")
  func testReplacedLogoKeptWhenSaveFails() async {
    let race = makeRace()
    let repository = StubRaceRepository(races: [race], writeOutcome: .failure(.raceSaveFailed))
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    viewModel.updatePhoto(with: UIImage())

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .raceSaveFailed)
    #expect(await storage.deletedURLs == ["https://example.com/uploaded.jpg"])
  }

  @Test("a logo uploaded for a new race is deleted when the race fails to save")
  func testNewRaceLogoDeletedWhenCreateFails() async {
    let repository = StubRaceRepository(writeOutcome: .failure(.raceSaveFailed))
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .add, race: nil, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    viewModel.updatePhoto(with: UIImage())

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .raceSaveFailed)
    #expect(await storage.deletedURLs == ["https://example.com/uploaded.jpg"])
  }

  @Test("a replaced edition photo is deleted from Storage once the edition saves")
  func testReplacedEditionPhotoDeletedAfterSave() async throws {
    let race = makeRace()
    let edition = try makeEdition()
    let repository = StubRaceRepository(races: [race], editions: [race.id: [edition]])
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    await viewModel.loadEditions()
    var draft = DraftRaceEdition(from: edition)
    draft.newPhotoData = try makePhotoData()
    draft.isModified = true
    viewModel.stageUpdateEdition(draft)

    await viewModel.save(by: "uid")

    #expect(await storage.deletedURLs == [editionPhotoUrl])
    #expect(
      await storage.deletedOwners == [.edition(raceId: "race-taipei", editionId: "edition-2025")])
  }

  @Test("an edition photo uploaded for a failed edition update is deleted")
  func testEditionUploadDeletedWhenUpdateFails() async throws {
    let race = makeRace()
    let edition = try makeEdition()
    let repository = StubRaceRepository(
      races: [race], editions: [race.id: [edition]], failingEditionUpdateIDs: [edition.id])
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    await viewModel.loadEditions()
    var draft = DraftRaceEdition(from: edition)
    draft.newPhotoData = try makePhotoData()
    draft.isModified = true
    viewModel.stageUpdateEdition(draft)

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .editionSaveFailed)
    #expect(await storage.deletedURLs == ["https://example.com/uploaded.jpg"])
  }

  @Test("an edition photo uploaded for a failed edition create is deleted")
  func testEditionUploadDeletedWhenCreateFails() async throws {
    let race = makeRace()
    let edition = try makeEdition()
    var draft = DraftRaceEdition(
      year: edition.year, isOneDay: true, startDate: edition.startDate,
      endDate: edition.endDate, distances: [], createdBy: "uid")
    draft.newPhotoData = try makePhotoData()
    let repository = StubRaceRepository(races: [race], failingEditionCreateIDs: [draft.id])
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    viewModel.stageAddEdition(draft)

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .editionSaveFailed)
    #expect(await storage.deletedURLs == ["https://example.com/uploaded.jpg"])
  }
}
