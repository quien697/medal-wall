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
      endDate: raceDay, photoUrl: editionPhotoUrl, raceEvents: [], createdBy: "uid")
  }

  @Test("a failed logo upload keeps the race's logo and fails the save")
  func testFailedLogoUploadKeepsLogo() async throws {
    let race = makeRace()
    let repository = StubRaceRepository(races: [race])
    let storage = StubPhotoStorage(uploadOutcome: .failure(.photoDataInvalid))
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    viewModel.photo.update(with: try TestPhotos.cropped())

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
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    viewModel.photo.remove()

    await viewModel.save(by: "uid")

    #expect(await storage.deletedURLs == [logoUrl])
    #expect(await repository.races.first?.photoUrl == nil)
  }

  @Test("a removed race logo stays in Storage when the race fails to save")
  func testRemovedLogoKeptWhenSaveFails() async {
    let race = makeRace()
    let repository = StubRaceRepository(races: [race], writeOutcome: .failure(.raceSaveFailed))
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    viewModel.photo.remove()

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .raceSaveFailed)
    #expect(await storage.deletedURLs.isEmpty)
  }

  @Test("a deleted edition's photo is deleted from Storage once the edition is deleted")
  func testDeletedEditionPhotoDeletedAfterDelete() async throws {
    let race = makeRace()
    let edition = try makeEdition()
    let repository = StubRaceRepository(races: [race], editions: [race.id: [edition]])
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    await viewModel.loadEditions()
    viewModel.stageDeleteEdition(id: edition.id)

    await viewModel.save(by: "uid")

    #expect(await storage.deletedURLs == [editionPhotoUrl])
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
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    await viewModel.loadEditions()
    viewModel.stageDeleteEdition(id: edition.id)

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .editionDeleteFailed)
    #expect(await storage.deletedURLs.isEmpty)
  }

  @Test("a removed edition photo is deleted from Storage once the edition saves")
  func testRemovedEditionPhotoDeletedAfterSave() async throws {
    let race = makeRace()
    let edition = try makeEdition()
    let repository = StubRaceRepository(races: [race], editions: [race.id: [edition]])
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    await viewModel.loadEditions()
    var draft = DraftRaceEdition(from: edition)
    draft.isPhotoRemoved = true
    draft.isModified = true
    viewModel.stageUpdateEdition(draft)

    await viewModel.save(by: "uid")

    #expect(await storage.deletedURLs == [editionPhotoUrl])
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
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    await viewModel.loadEditions()
    var draft = DraftRaceEdition(from: edition)
    draft.isPhotoRemoved = true
    draft.isModified = true
    viewModel.stageUpdateEdition(draft)

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .editionSaveFailed)
    #expect(await storage.deletedURLs.isEmpty)
  }

  @Test("a failed photo upload keeps an edition's photo and fails the save")
  func testFailedEditionUploadKeepsPhoto() async throws {
    let race = makeRace()
    let edition = try makeEdition()
    let repository = StubRaceRepository(races: [race], editions: [race.id: [edition]])
    let storage = StubPhotoStorage(uploadOutcome: .failure(.photoDataInvalid))
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    await viewModel.loadEditions()
    var draft = DraftRaceEdition(from: edition)
    draft.newPhoto = try TestPhotos.cropped()
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
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    let edition = try makeEdition()
    var draft = DraftRaceEdition(
      year: edition.year, isOneDay: true, startDate: edition.startDate,
      endDate: edition.endDate, distances: [], createdBy: "uid")
    draft.newPhoto = try TestPhotos.cropped()
    viewModel.stageAddEdition(draft)

    await viewModel.save(by: "uid")

    #expect(viewModel.error == nil)
    #expect(await storage.uploadedEditionPhotoIDs == [draft.id])
    #expect(await repository.createdEditions.first?.photoUrl == "https://example.com/uploaded.jpg")
  }

  @Test("a failed photo upload for a new edition leaves it unsaved and fails the save")
  func testFailedNewEditionUploadSkipsCreate() async throws {
    let race = makeRace()
    let repository = StubRaceRepository(races: [race])
    let storage = StubPhotoStorage(uploadOutcome: .failure(.photoDataInvalid))
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    let edition = try makeEdition()
    var draft = DraftRaceEdition(
      year: edition.year, isOneDay: true, startDate: edition.startDate,
      endDate: edition.endDate, distances: [], createdBy: "uid")
    draft.newPhoto = try TestPhotos.cropped()
    viewModel.stageAddEdition(draft)

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .editionSaveFailed)
    #expect(await repository.createdEditions.isEmpty)
  }

  // MARK: - Retrying a partly failed save
  @Test("retrying a save after a failed edition write does not upload the race logo again")
  func testRetryDoesNotReuploadRaceLogo() async throws {
    let race = makeRace()
    let edition = try makeEdition()
    let repository = StubRaceRepository(
      races: [race], editions: [race.id: [edition]], failingEditionUpdateIDs: [edition.id])
    let storage = StubPhotoStorage()
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    await viewModel.loadEditions()
    viewModel.photo.update(with: try TestPhotos.cropped())
    var draft = DraftRaceEdition(from: edition)
    draft.isModified = true
    viewModel.stageUpdateEdition(draft)

    await viewModel.save(by: "uid")
    viewModel.error = nil  // what dismissing the error sheet does
    await viewModel.save(by: "uid")

    #expect(await storage.uploadCallCount == 1)
    #expect(await storage.deletedURLs == [logoUrl])
  }

  /// Stages an update to `edition` with a new photo, plus an update that fails to save.
  private func makeViewModelWithFailingSibling(
    of edition: RaceEdition, storage: StubPhotoStorage, stage: (inout DraftRaceEdition) -> Void
  ) async -> EditRaceViewModel {
    let race = makeRace()
    let failing = RaceEdition(
      id: "edition-2024", raceId: race.id, year: 2024, startDate: edition.startDate,
      endDate: edition.endDate, raceEvents: [], createdBy: "uid")
    let repository = StubRaceRepository(
      races: [race], editions: [race.id: [edition, failing]],
      failingEditionUpdateIDs: [failing.id])
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    await viewModel.loadEditions()
    var draft = DraftRaceEdition(from: edition)
    stage(&draft)
    draft.isModified = true
    viewModel.stageUpdateEdition(draft)
    var failingDraft = DraftRaceEdition(from: failing)
    failingDraft.isModified = true
    viewModel.stageUpdateEdition(failingDraft)
    return viewModel
  }

  @Test("retrying a save after a failed update does not upload a saved edition's photo twice")
  func testRetryDoesNotReuploadEditionPhoto() async throws {
    let edition = try makeEdition()
    let photo = try TestPhotos.cropped()
    let storage = StubPhotoStorage()
    let viewModel = await makeViewModelWithFailingSibling(of: edition, storage: storage) {
      $0.newPhoto = photo
    }

    await viewModel.save(by: "uid")
    viewModel.error = nil  // what dismissing the error sheet does
    await viewModel.save(by: "uid")

    #expect(await storage.uploadedEditionPhotoIDs == [edition.id])
  }

  @Test("retrying a save after a failed update does not delete a saved edition's photo twice")
  func testRetryDoesNotRedeleteEditionPhoto() async throws {
    let edition = try makeEdition()
    let storage = StubPhotoStorage()
    let viewModel = await makeViewModelWithFailingSibling(of: edition, storage: storage) {
      $0.isPhotoRemoved = true
    }

    await viewModel.save(by: "uid")
    viewModel.error = nil  // what dismissing the error sheet does
    await viewModel.save(by: "uid")

    #expect(await storage.deletedURLs == [editionPhotoUrl])
  }

  // MARK: - Offline
  @Test("saving offline is refused before anything is uploaded or written")
  func testOfflineSaveIsRefused() async throws {
    let race = makeRace()
    let repository = StubRaceRepository(races: [race])
    let storage = StubPhotoStorage()
    let networkMonitor = StubNetworkMonitor()
    networkMonitor.isConnectedNow = false
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: networkMonitor)
    viewModel.photo.update(with: try TestPhotos.cropped())

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .noInternetConnection)
    #expect(await storage.uploadCallCount == 0)
    #expect(await repository.updatedRaces.isEmpty)
  }
}

// MARK: - Photo Too Large
extension EditRaceViewModelStorageTests {
  @Test("a new race whose logo Storage refuses as too large fails with Photo Too Large")
  func testNewRaceLogoTooLarge() async throws {
    let repository = StubRaceRepository()
    let storage = StubPhotoStorage(uploadOutcome: .failure(.photoTooLarge))
    let viewModel = EditRaceViewModel(
      mode: .add, race: nil, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    viewModel.name = "Taipei Marathon"
    viewModel.place = Place(countryCode: "TW", city: "Taipei City")
    viewModel.photo.update(with: try TestPhotos.cropped())

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .photoTooLarge)
    #expect(await repository.races.isEmpty)
  }

  @Test("a race logo Storage refuses as too large fails the save with Photo Too Large")
  func testLogoTooLarge() async throws {
    let race = makeRace()
    let repository = StubRaceRepository(races: [race])
    let storage = StubPhotoStorage(uploadOutcome: .failure(.photoTooLarge))
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    viewModel.photo.update(with: try TestPhotos.cropped())

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .photoTooLarge)
    #expect(await repository.races.first?.photoUrl == logoUrl)
  }

  @Test("an edition photo Storage refuses as too large fails the save with Photo Too Large")
  func testEditionPhotoTooLarge() async throws {
    let race = makeRace()
    let edition = try makeEdition()
    let repository = StubRaceRepository(races: [race], editions: [race.id: [edition]])
    let storage = StubPhotoStorage(uploadOutcome: .failure(.photoTooLarge))
    let viewModel = EditRaceViewModel(
      mode: .edit, race: race, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    await viewModel.loadEditions()
    var draft = DraftRaceEdition(from: edition)
    draft.newPhoto = try TestPhotos.cropped()
    draft.isModified = true
    viewModel.stageUpdateEdition(draft)

    await viewModel.save(by: "uid")

    #expect(viewModel.error == .photoTooLarge)
    #expect(await repository.editions[race.id]?.first?.photoUrl == editionPhotoUrl)
  }
}
