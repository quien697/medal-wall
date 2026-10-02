//
//  EditRaceViewModelStorageTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-30.
//

import Foundation
import Testing
import UIKit

@testable import MedalWall

@MainActor
struct EditRaceViewModelStorageTests {

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

  @Test("a failed logo upload keeps the race's logo and fails the save")
  func testFailedLogoUploadKeepsLogo() async {
    let race = makeRace()
    let repository = StubRaceRepository(races: [race])
    let storage = StubPhotoStorage(uploadOutcome: .failure(.photoDataInvalid))
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage)
    viewModel.updatePhoto(with: UIImage())

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .raceSaveFailed)
    #expect(await repository.races.first?.photoUrl == logoUrl)
  }

  @Test("a removed race logo is deleted from Storage once the race saves")
  func testRemovedLogoDeletedAfterSave() async {
    let race = makeRace()
    let repository = StubRaceRepository(races: [race])
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage)
    viewModel.clearPhoto()

    await viewModel.save(by: "uid")

    #expect(await storage.raceLogoDeleteCount == 1)
    #expect(await repository.races.first?.photoUrl == nil)
  }

  @Test("a removed race logo stays in Storage when the race fails to save")
  func testRemovedLogoKeptWhenSaveFails() async {
    let race = makeRace()
    let repository = StubRaceRepository(races: [race], writeOutcome: .failure(.raceSaveFailed))
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage)
    viewModel.clearPhoto()

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .raceSaveFailed)
    #expect(await storage.raceLogoDeleteCount == 0)
  }

  @Test("a deleted edition's photo is deleted from Storage once the edition is deleted")
  func testDeletedEditionPhotoDeletedAfterDelete() async throws {
    let race = makeRace()
    let edition = try makeEdition()
    let repository = StubRaceRepository(races: [race], editions: [race.id: [edition]])
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage)
    await viewModel.loadEditions()
    viewModel.stageDeleteEdition(id: edition.id)

    await viewModel.save(by: "uid")

    #expect(await storage.deletedEditionLogoIDs == [edition.id])
  }

  @Test("a deleted edition's photo stays in Storage when the edition fails to delete")
  func testDeletedEditionPhotoKeptWhenDeleteFails() async throws {
    let race = makeRace()
    let edition = try makeEdition()
    let repository = StubRaceRepository(
      races: [race], editions: [race.id: [edition]],
      deleteOutcome: .failure(.editionDeleteFailed))
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage)
    await viewModel.loadEditions()
    viewModel.stageDeleteEdition(id: edition.id)

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .editionDeleteFailed)
    #expect(await storage.deletedEditionLogoIDs.isEmpty)
  }

  @Test("a removed edition photo is deleted from Storage once the edition saves")
  func testRemovedEditionPhotoDeletedAfterSave() async throws {
    let race = makeRace()
    let edition = try makeEdition()
    let repository = StubRaceRepository(races: [race], editions: [race.id: [edition]])
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage)
    await viewModel.loadEditions()
    var draft = DraftRaceEdition(from: edition)
    draft.isPhotoCleared = true
    draft.isModified = true
    viewModel.stageUpdateEdition(draft)

    await viewModel.save(by: "uid")

    #expect(await storage.deletedEditionLogoIDs == [edition.id])
    #expect(await repository.editions[race.id]?.first?.photoUrl == nil)
  }

  @Test("a removed edition photo stays in Storage when the edition fails to save")
  func testRemovedEditionPhotoKeptWhenSaveFails() async throws {
    let race = makeRace()
    let edition = try makeEdition()
    let repository = StubRaceRepository(
      races: [race], editions: [race.id: [edition]], failingEditionUpdateIDs: [edition.id])
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage)
    await viewModel.loadEditions()
    var draft = DraftRaceEdition(from: edition)
    draft.isPhotoCleared = true
    draft.isModified = true
    viewModel.stageUpdateEdition(draft)

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .editionSaveFailed)
    #expect(await storage.deletedEditionLogoIDs.isEmpty)
  }

  @Test("a failed photo upload keeps an edition's photo and fails the save")
  func testFailedEditionUploadKeepsPhoto() async throws {
    let race = makeRace()
    let edition = try makeEdition()
    let repository = StubRaceRepository(races: [race], editions: [race.id: [edition]])
    let storage = StubPhotoStorage(uploadOutcome: .failure(.photoDataInvalid))
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage)
    await viewModel.loadEditions()
    var draft = DraftRaceEdition(from: edition)
    draft.newPhotoData = try makePhotoData()
    draft.isModified = true
    viewModel.stageUpdateEdition(draft)

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .editionSaveFailed)
    #expect(await repository.editions[race.id]?.first?.photoUrl == editionPhotoUrl)
  }

  @Test("a new edition's photo is uploaded under its id and its URL saved")
  func testNewEditionUploadSavesPhotoUrl() async throws {
    let race = makeRace()
    let repository = StubRaceRepository(races: [race])
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage)
    let edition = try makeEdition()
    var draft = DraftRaceEdition(
      year: edition.year, isOneDay: true, startDate: edition.startDate,
      endDate: edition.endDate, distances: [], createdBy: "uid")
    draft.newPhotoData = try makePhotoData()
    viewModel.stageAddEdition(draft)

    await viewModel.save(by: "uid")

    #expect(viewModel.error == nil)
    #expect(await storage.uploadedEditionLogoIDs == [draft.id])
    #expect(await repository.createdEditions.first?.photoUrl == "https://example.com/uploaded.jpg")
  }

  @Test("a failed photo upload for a new edition leaves it unsaved and fails the save")
  func testFailedNewEditionUploadSkipsCreate() async throws {
    let race = makeRace()
    let repository = StubRaceRepository(races: [race])
    let storage = StubPhotoStorage(uploadOutcome: .failure(.photoDataInvalid))
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage)
    let edition = try makeEdition()
    var draft = DraftRaceEdition(
      year: edition.year, isOneDay: true, startDate: edition.startDate,
      endDate: edition.endDate, distances: [], createdBy: "uid")
    draft.newPhotoData = try makePhotoData()
    viewModel.stageAddEdition(draft)

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .editionSaveFailed)
    #expect(await repository.createdEditions.isEmpty)
  }
}
