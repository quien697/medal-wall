//
//  EditMedalViewModelStorageTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-30.
//

import Foundation
import Testing
import UIKit

@testable import MedalWall

@MainActor
struct EditMedalViewModelStorageTests {

  private let photoUrl = "https://example.com/medal.jpg"

  private func makeMedal() -> Medal {
    Medal(
      id: "medal-taipei",
      name: "Taipei Marathon",
      date: Date(timeIntervalSince1970: 1_577_836_800),
      bibNumber: "00001",
      photoUrl: photoUrl,
      place: Place(countryCode: "TW", city: "Taipei City"),
      distance: .default,
      userID: "uid"
    )
  }

  private func makeViewModel(
    repository: StubMedalRepository, storage: StubPhotoStorage
  ) -> EditMedalViewModel {
    EditMedalViewModel(
      mode: .edit, medal: makeMedal(), repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
  }

  private func makePhotoData() throws -> Data {
    let image = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
      UIColor.red.setFill()
      context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    return try #require(image.pngData())
  }

  @Test("an unchanged cover photo keeps its URL and is not uploaded again")
  func testUnchangedPhotoIsNotReuploaded() async throws {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.photo = UIImage()  // what loadPhoto leaves behind: the existing photo

    try await viewModel.save(by: "uid")

    #expect(await storage.uploadCallCount == 0)
    #expect(await repository.updatedMedals.first?.photoUrl == photoUrl)
  }

  @Test("removing the cover photo clears its URL")
  func testRemovedPhotoClearsURL() async throws {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.clearPhoto()

    try await viewModel.save(by: "uid")

    #expect(await repository.updatedMedals.first?.photoUrl == nil)
  }

  @Test("a removed cover photo is deleted from Storage once the medal saves")
  func testRemovedPhotoDeletedAfterSave() async throws {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.clearPhoto()

    try await viewModel.save(by: "uid")

    #expect(await storage.deletedURLs == [photoUrl])
  }

  @Test("a removed cover photo stays in Storage when the medal fails to save")
  func testRemovedPhotoKeptWhenSaveFails() async {
    let repository = StubMedalRepository(
      medals: [makeMedal()], writeOutcome: .failure(.medalSaveFailed))
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.clearPhoto()

    await #expect(throws: AppError.medalSaveFailed) {
      try await viewModel.save(by: "uid")
    }

    #expect(await storage.deletedURLs.isEmpty)
  }

  @Test("a newly picked cover photo is uploaded")
  func testPickedPhotoIsUploaded() async throws {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.updatePhoto(with: UIImage())

    try await viewModel.save(by: "uid")

    #expect(await storage.uploadCallCount == 1)
    #expect(await repository.updatedMedals.first?.photoUrl == "https://example.com/uploaded.jpg")
  }

  @Test("a replaced cover photo is deleted from Storage once the medal saves")
  func testReplacedPhotoDeletedAfterSave() async throws {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.updatePhoto(with: UIImage())

    try await viewModel.save(by: "uid")

    #expect(await storage.deletedURLs == [photoUrl])
  }

  @Test("a replaced cover photo stays in Storage and the new upload is deleted when the save fails")
  func testReplacedPhotoKeptWhenSaveFails() async {
    let repository = StubMedalRepository(
      medals: [makeMedal()], writeOutcome: .failure(.medalSaveFailed))
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.updatePhoto(with: UIImage())

    await #expect(throws: AppError.medalSaveFailed) {
      try await viewModel.save(by: "uid")
    }

    #expect(await storage.deletedURLs == ["https://example.com/uploaded.jpg"])
  }

  @Test("photos uploaded for a new medal are deleted when it fails to save")
  func testUploadsDeletedWhenCreateFails() async throws {
    let repository = StubMedalRepository(writeOutcome: .failure(.medalSaveFailed))
    let storage = StubPhotoStorage()
    let viewModel = EditMedalViewModel(
      mode: .add, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    viewModel.updatePhoto(with: UIImage())
    viewModel.addEventPhotos([try makePhotoData()])

    await #expect(throws: AppError.medalSaveFailed) {
      try await viewModel.save(by: "uid")
    }

    #expect(await storage.uploadCallCount == 2)
    #expect(
      await storage.deletedURLs == [
        "https://example.com/uploaded.jpg", "https://example.com/uploaded.jpg"
      ])
  }

  // MARK: - Event photos
  private func makeMedalWithEventPhotos() -> Medal {
    var medal = makeMedal()
    medal.eventPhotos = [
      EventPhoto(id: "event-start", imageUrl: "https://example.com/start.jpg", sortOrder: 0),
      EventPhoto(id: "event-finish", imageUrl: "https://example.com/finish.jpg", sortOrder: 1)
    ]
    return medal
  }

  @Test("a removed event photo is deleted from Storage once the medal saves")
  func testRemovedEventPhotoDeletedAfterSave() async throws {
    let medal = makeMedalWithEventPhotos()
    let repository = StubMedalRepository(medals: [medal])
    let storage = StubPhotoStorage()
    let viewModel = EditMedalViewModel(
      mode: .edit, medal: medal, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    viewModel.removeEventPhoto(id: "event-start")

    try await viewModel.save(by: "uid")

    #expect(await storage.deletedURLs == ["https://example.com/start.jpg"])
    #expect(await repository.updatedMedals.first?.eventPhotos.map(\.id) == ["event-finish"])
  }

  @Test("a removed event photo stays in Storage when the medal fails to save")
  func testRemovedEventPhotoKeptWhenSaveFails() async {
    let medal = makeMedalWithEventPhotos()
    let repository = StubMedalRepository(
      medals: [medal], writeOutcome: .failure(.medalSaveFailed))
    let storage = StubPhotoStorage()
    let viewModel = EditMedalViewModel(
      mode: .edit, medal: medal, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    viewModel.removeEventPhoto(id: "event-start")

    await #expect(throws: AppError.medalSaveFailed) {
      try await viewModel.save(by: "uid")
    }

    #expect(await storage.deletedURLs.isEmpty)
  }

  @Test("an event photo added to a medal that fails to save is deleted from Storage")
  func testAddedEventPhotoDeletedWhenSaveFails() async throws {
    let medal = makeMedalWithEventPhotos()
    let repository = StubMedalRepository(
      medals: [medal], writeOutcome: .failure(.medalSaveFailed))
    let storage = StubPhotoStorage()
    let viewModel = EditMedalViewModel(
      mode: .edit, medal: medal, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    viewModel.addEventPhotos([try makePhotoData()])

    await #expect(throws: AppError.medalSaveFailed) {
      try await viewModel.save(by: "uid")
    }

    #expect(await storage.deletedURLs == ["https://example.com/uploaded.jpg"])
  }

  // MARK: - Offline
  @Test("saving offline is refused before anything is uploaded or written")
  func testOfflineSaveIsRefused() async {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let networkMonitor = StubNetworkMonitor()
    networkMonitor.isConnectedNow = false
    let viewModel = EditMedalViewModel(
      mode: .edit, medal: makeMedal(), repository: repository, storageService: storage,
      networkMonitor: networkMonitor)
    viewModel.updatePhoto(with: UIImage())

    await #expect(throws: AppError.noInternetConnection) {
      try await viewModel.save(by: "uid")
    }

    #expect(await storage.uploadCallCount == 0)
    #expect(await repository.updatedMedals.isEmpty)
  }
}
