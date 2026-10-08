//
//  MedalDetailViewModelRepositoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-22.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct MedalDetailViewModelRepositoryTests {

  private func makeMedal(id: String = "medal-a", name: String = "Taipei Marathon") -> Medal {
    Medal(
      id: id,
      name: name,
      date: Date(timeIntervalSince1970: 1_577_836_800),
      bibNumber: "00001",
      place: Place(countryCode: "TW", city: "Taipei City"),
      distance: .default,
      userID: "uid"
    )
  }

  @Test("a deleted medal leaves the store")
  func testDeleteMedal() async throws {
    let medal = makeMedal()
    let repository = StubMedalRepository(medals: [medal])
    let viewModel = MedalDetailViewModel(medal: medal, repository: repository)

    try await viewModel.deleteMedal()

    #expect(await repository.deletedMedalIDs == [medal.id])
    #expect(await repository.medals.isEmpty)
  }

  @Test("a failed delete throws and keeps the medal")
  func testFailedDeleteThrows() async {
    let medal = makeMedal()
    let repository = StubMedalRepository(
      medals: [medal], deleteOutcome: .failure(.medalDeleteFailed))
    let viewModel = MedalDetailViewModel(medal: medal, repository: repository)

    await #expect(throws: AppError.medalDeleteFailed) {
      try await viewModel.deleteMedal()
    }
    #expect(await repository.medals.count == 1)
  }

  @Test("a reload picks up an edit made elsewhere")
  func testReloadUpdatesMedal() async throws {
    let medal = makeMedal()
    let repository = StubMedalRepository(medals: [medal])
    let viewModel = MedalDetailViewModel(medal: medal, repository: repository)
    try? await repository.updateMedal(makeMedal(name: "Taipei Marathon 2019"))

    try await viewModel.reloadMedal()

    #expect(viewModel.medal.name == "Taipei Marathon 2019")
  }

  @Test("a reload that fails says so and keeps the medal on screen")
  func testFailedReloadThrows() async {
    let medal = makeMedal()
    let repository = StubMedalRepository(medals: [medal], fetchOutcome: .failure(.unknown))
    let viewModel = MedalDetailViewModel(medal: medal, repository: repository)

    let error = await #expect(throws: AppError.self) {
      try await viewModel.reloadMedal()
    }

    guard case .medalFetchFailed = error else {
      Issue.record("expected medalFetchFailed, got \(String(describing: error))")
      return
    }
    #expect(viewModel.medal.name == "Taipei Marathon")
  }

  // MARK: - Photos
  private func makeMedalWithPhotos() -> Medal {
    var medal = makeMedal()
    medal.photoUrl = "https://example.com/medal.jpg"
    medal.eventPhotos = [
      EventPhoto(id: "event-start", imageUrl: "https://example.com/start.jpg", sortOrder: 0),
      EventPhoto(id: "event-finish", imageUrl: "https://example.com/finish.jpg", sortOrder: 1)
    ]
    return medal
  }

  @Test("a deleted medal's photos are deleted from Storage once the medal is deleted")
  func testDeletedMedalPhotosDeletedAfterDelete() async throws {
    let medal = makeMedalWithPhotos()
    let storage = StubPhotoStorage()
    let viewModel = MedalDetailViewModel(
      medal: medal, repository: StubMedalRepository(medals: [medal]), storageService: storage)

    try await viewModel.deleteMedal()

    #expect(await storage.medalPhotoDeleteCount == 1)
    #expect(await storage.deletedEventPhotoIDs == ["event-start", "event-finish"])
  }

  @Test("a medal's photos stay in Storage when the medal fails to delete")
  func testMedalPhotosKeptWhenDeleteFails() async {
    let medal = makeMedalWithPhotos()
    let storage = StubPhotoStorage()
    let viewModel = MedalDetailViewModel(
      medal: medal,
      repository: StubMedalRepository(
        medals: [medal], deleteOutcome: .failure(.medalDeleteFailed)),
      storageService: storage)

    await #expect(throws: AppError.medalDeleteFailed) {
      try await viewModel.deleteMedal()
    }

    #expect(await storage.medalPhotoDeleteCount == 0)
    #expect(await storage.deletedEventPhotoIDs.isEmpty)
  }
}
