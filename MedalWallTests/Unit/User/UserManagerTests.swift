//
//  UserManagerTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-30.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct UserManagerTests {

  private let uid = "uid-new"
  private let email = "runner@example.com"

  @Test("a first sign-in writes the new profile before it returns")
  func testFirstSignInWritesProfile() async {
    let repository = StubUserRepository(createLatency: .milliseconds(200))
    let authService = StubAuthService()
    let manager = UserManager(repository: repository, authService: authService)

    await authService.report((uid: uid, email: email))

    #expect(manager.currentUser?.email == email)
    #expect(await repository.createdUsers.map(\.uid) == [uid])
  }
}
