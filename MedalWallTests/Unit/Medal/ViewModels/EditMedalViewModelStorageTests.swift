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
      mode: .edit, medal: makeMedal(), repository: repository, storageService: storage)
  }

  private func makeUserManager() -> UserManager {
    UserManager(repository: StubUserRepository())
  }

  @Test("an unchanged cover photo keeps its URL and is not uploaded again")
  func testUnchangedPhotoIsNotReuploaded() async throws {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.photo = UIImage()  // what loadPhoto leaves behind: the existing photo

    try await viewModel.save(by: "uid", userManager: makeUserManager())

    #expect(await storage.uploadCallCount == 0)
    #expect(await repository.updatedMedals.first?.photoUrl == photoUrl)
  }

  @Test("removing the cover photo clears its URL")
  func testRemovedPhotoClearsURL() async throws {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.clearPhoto()

    try await viewModel.save(by: "uid", userManager: makeUserManager())

    #expect(await repository.updatedMedals.first?.photoUrl == nil)
  }

  @Test("a newly picked cover photo is uploaded")
  func testPickedPhotoIsUploaded() async throws {
    let repository = StubMedalRepository(medals: [makeMedal()])
    let storage = StubPhotoStorage()
    let viewModel = makeViewModel(repository: repository, storage: storage)
    viewModel.updatePhoto(with: UIImage())

    try await viewModel.save(by: "uid", userManager: makeUserManager())

    #expect(await storage.uploadCallCount == 1)
    #expect(await repository.updatedMedals.first?.photoUrl == "https://example.com/uploaded.jpg")
  }
}
