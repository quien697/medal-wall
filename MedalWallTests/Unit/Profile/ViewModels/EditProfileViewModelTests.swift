//
//  EditProfileViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-02.
//

import Foundation
import Testing
import UIKit

@testable import MedalWall

@MainActor
struct EditProfileViewModelTests {

  private let avatarUrl = "https://example.com/avatar.jpg"

  private func makeProfile(
    birthday: Date? = nil, photoUrl: String? = nil, bio: String? = nil
  ) -> User {
    User(
      uid: "uid", email: "runner@example.com", firstName: "John", lastName: "Doe",
      photoUrl: photoUrl, bio: bio, birthday: birthday)
  }

  @Test("an unset birthday survives a save")
  func testUnsetBirthdayStaysUnset() {
    let viewModel = EditProfileViewModel(profile: makeProfile())

    #expect(viewModel.birthday == nil)
    #expect(viewModel.makeUpdatedUser().birthday == nil)
  }

  @Test("an existing birthday round-trips unchanged")
  func testExistingBirthdayRoundTrips() {
    let stored = Date(timeIntervalSince1970: 631_152_000)  // 1990-01-01
    let viewModel = EditProfileViewModel(profile: makeProfile(birthday: stored))

    #expect(viewModel.birthday == stored)
    #expect(viewModel.makeUpdatedUser().birthday == stored)
  }

  @Test("a birthday reset to nil is not written back as a date")
  func testNilBirthdayIsNotWrittenBack() {
    let viewModel = EditProfileViewModel(profile: makeProfile(birthday: .now))

    viewModel.birthday = nil

    #expect(viewModel.makeUpdatedUser().birthday == nil)
  }

  @Test("a bio is saved without surrounding whitespace or line breaks")
  func testBioSavedTrimmed() {
    let viewModel = EditProfileViewModel(profile: makeProfile())

    viewModel.bio = "\n Sub-4 or bust \n"

    #expect(viewModel.makeUpdatedUser().bio == "Sub-4 or bust")
  }

  @Test("an empty or whitespace-only bio is saved as no bio", arguments: ["", " \n "])
  func testBlankBioSavedAsNil(bio: String) {
    let viewModel = EditProfileViewModel(profile: makeProfile(bio: "Sub-4 or bust"))

    viewModel.bio = bio

    #expect(viewModel.makeUpdatedUser().bio == nil)
  }

  @Test("a photo picked while the existing one loads is kept")
  func testPickedPhotoSurvivesExistingPhotoLoad() async {
    let viewModel = EditProfileViewModel(profile: makeProfile())
    let pickedPhoto = UIImage()
    viewModel.updatePhoto(with: pickedPhoto)

    await viewModel.loadExistingPhoto()

    #expect(viewModel.photo === pickedPhoto)
  }

  @Test("an untouched photo keeps its URL and is not re-uploaded")
  func testUntouchedPhotoKeepsURL() {
    let viewModel = EditProfileViewModel(profile: makeProfile(photoUrl: avatarUrl))

    #expect(viewModel.makeUpdatedUser().photoUrl == avatarUrl)
    #expect(viewModel.photoToUpload == nil)
  }

  @Test("removing the photo clears its URL")
  func testRemovedPhotoClearsURL() {
    let viewModel = EditProfileViewModel(profile: makeProfile(photoUrl: avatarUrl))

    viewModel.clearPhoto()

    #expect(viewModel.makeUpdatedUser().photoUrl == nil)
    #expect(viewModel.photoToUpload == nil)
  }

  @Test("a newly picked photo is the one uploaded")
  func testPickedPhotoIsUploaded() {
    let viewModel = EditProfileViewModel(profile: makeProfile(photoUrl: avatarUrl))
    let pickedPhoto = UIImage()

    viewModel.updatePhoto(with: pickedPhoto)

    #expect(viewModel.photoToUpload === pickedPhoto)
  }

  @Test("saving offline is refused before anything is uploaded or written")
  func testOfflineSaveIsRefused() async {
    let repository = StubUserRepository(user: makeProfile(photoUrl: avatarUrl))
    let storage = StubPhotoStorage()
    let manager = UserManager(
      repository: repository, authService: StubAuthService(),
      networkMonitor: StubNetworkMonitor(), storageService: storage)
    let networkMonitor = StubNetworkMonitor()
    networkMonitor.isConnectedNow = false
    let viewModel = EditProfileViewModel(
      profile: makeProfile(photoUrl: avatarUrl), networkMonitor: networkMonitor)
    viewModel.updatePhoto(with: UIImage())

    await #expect(throws: AppError.noInternetConnection) {
      try await viewModel.save(userManager: manager)
    }

    #expect(await storage.uploadCallCount == 0)
    #expect(await repository.updatedUsers.isEmpty)
  }
}
