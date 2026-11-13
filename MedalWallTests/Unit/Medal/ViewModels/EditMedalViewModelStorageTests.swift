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

  private let frontUrl = "https://example.com/front.png"
  private let backUrl = "https://example.com/back.png"
  private let uploadedUrl = "https://example.com/uploaded.jpg"

  private func makeMedal() -> Medal {
    Medal(
      id: "medal-taipei",
      name: "Taipei Marathon",
      date: Date(timeIntervalSince1970: 1_577_836_800),
      bibNumber: "00001",
      photoUrls: MedalPhotoUrls(front: frontUrl, back: backUrl),
      place: Place(countryCode: "TW", city: "Taipei City"),
      raceEvent: .default,
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

  // MARK: - Faces
  @Test("untouched faces keep their URLs and are not uploaded again")
  func testUntouchedFacesAreNotReuploaded() async throws {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)

    try await viewModel.save(by: "uid")

    #expect(await storage.uploadCallCount == 0)
    #expect(await repository.updatedMedals.first?.photoUrls?.front == frontUrl)
    #expect(await repository.updatedMedals.first?.photoUrls?.back == backUrl)
  }

  @Test("a changed face is uploaded as that face, and the other face is untouched")
  func testChangedFaceIsUploadedAsItsFace() async throws {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.updatePhoto(with: UIImage(), for: .back)

    try await viewModel.save(by: "uid")

    #expect(await storage.uploadedFaces == [.back])
    #expect(await repository.updatedMedals.first?.photoUrls?.back == uploadedUrl)
    #expect(await repository.updatedMedals.first?.photoUrls?.front == frontUrl)
  }

  @Test("removing the front clears its URL and keeps the back")
  func testRemovedFaceClearsURL() async throws {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.clearPhoto(for: .front)

    try await viewModel.save(by: "uid")

    #expect(await repository.updatedMedals.first?.photoUrls?.front == nil)
    #expect(await repository.updatedMedals.first?.photoUrls?.back == backUrl)
  }

  @Test("removing both faces stores no photo URLs at all, not an empty map")
  func testRemovingBothFacesStoresNoPhotoUrls() async throws {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.clearPhoto(for: .front)
    viewModel.clearPhoto(for: .back)

    try await viewModel.save(by: "uid")

    let updated = try #require(await repository.updatedMedals.first)
    #expect(updated.photoUrls == nil)
  }

  @Test("a removed face is deleted from Storage once the medal saves")
  func testRemovedFaceDeletedAfterSave() async throws {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.clearPhoto(for: .front)

    try await viewModel.save(by: "uid")

    #expect(await storage.deletedURLs == [frontUrl])
  }

  @Test("a removed face stays in Storage when the medal fails to save")
  func testRemovedFaceKeptWhenSaveFails() async {
    let repository = StubMedalRepository(
      medals: [makeMedal()], writeOutcome: .failure(.medalSaveFailed))
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.clearPhoto(for: .back)

    await #expect(throws: AppError.medalSaveFailed) {
      try await viewModel.save(by: "uid")
    }

    #expect(await storage.deletedURLs.isEmpty)
  }

  @Test("a replaced face is deleted from Storage once the medal saves")
  func testReplacedFaceDeletedAfterSave() async throws {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.updatePhoto(with: UIImage(), for: .front)

    try await viewModel.save(by: "uid")

    #expect(await storage.deletedURLs == [frontUrl])
    #expect(await storage.deletedOwners == [.medal(userId: "uid", medalId: "medal-taipei")])
  }

  @Test("a replaced face stays in Storage and the new upload is deleted when the save fails")
  func testReplacedFaceKeptWhenSaveFails() async {
    let repository = StubMedalRepository(
      medals: [makeMedal()], writeOutcome: .failure(.medalSaveFailed))
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.updatePhoto(with: UIImage(), for: .front)

    await #expect(throws: AppError.medalSaveFailed) {
      try await viewModel.save(by: "uid")
    }

    #expect(await storage.deletedURLs == [uploadedUrl])
  }

  @Test("photos uploaded for a new medal are deleted when it fails to save")
  func testUploadsDeletedWhenCreateFails() async throws {
    let repository = StubMedalRepository(writeOutcome: .failure(.medalSaveFailed))
    let storage = StubPhotoStorage()
    let viewModel = EditMedalViewModel(
      mode: .add, repository: repository, storageService: storage,
      networkMonitor: StubNetworkMonitor())
    viewModel.updatePhoto(with: UIImage(), for: .front)
    viewModel.updatePhoto(with: UIImage(), for: .back)
    viewModel.addEventPhotos([try makePhotoData()])

    await #expect(throws: AppError.medalSaveFailed) {
      try await viewModel.save(by: "uid")
    }

    #expect(await storage.uploadCallCount == 3)
    #expect(await storage.deletedURLs == [uploadedUrl, uploadedUrl, uploadedUrl])
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
    #expect(await storage.deletedOwners == [.medal(userId: "uid", medalId: "medal-taipei")])
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
    viewModel.updatePhoto(with: UIImage(), for: .front)

    await #expect(throws: AppError.noInternetConnection) {
      try await viewModel.save(by: "uid")
    }

    #expect(await storage.uploadCallCount == 0)
    #expect(await repository.updatedMedals.isEmpty)
  }
}
