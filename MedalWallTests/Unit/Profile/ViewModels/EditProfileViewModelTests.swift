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

  private func makeProfile(birthday: Date? = nil, photoUrl: String? = nil) -> User {
    User(
      uid: "uid", email: "runner@example.com", firstName: "John", lastName: "Doe",
      photoUrl: photoUrl, birthday: birthday)
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
}
