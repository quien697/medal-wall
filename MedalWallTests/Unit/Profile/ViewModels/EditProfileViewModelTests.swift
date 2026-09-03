//
//  EditProfileViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-02.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct EditProfileViewModelTests {

  private func makeProfile(birthday: Date? = nil) -> User {
    User(
      uid: "uid", email: "runner@example.com", firstName: "John", lastName: "Doe",
      birthday: birthday)
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
}
