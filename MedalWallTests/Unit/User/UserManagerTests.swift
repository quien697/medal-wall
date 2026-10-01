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

  @Test(
    "a first sign-in finishes while the new profile's write is unacknowledged",
    .timeLimit(.minutes(1))
  )
  func testFirstSignInDoesNotWaitForProfileWrite() async {
    let repository = StubUserRepository(holdsCreates: true)
    let manager = UserManager(repository: repository)

    let user = await manager.loadOrFetchUser(uid: uid, email: email)

    #expect(user.uid == uid)
    #expect(user.email == email)
    await repository.releaseCreates()
  }

  @Test("a first sign-in writes the new profile")
  func testFirstSignInWritesProfile() async throws {
    let repository = StubUserRepository()
    let manager = UserManager(repository: repository)

    _ = await manager.loadOrFetchUser(uid: uid, email: email)

    var attempts = 0
    while attempts < 100, !(await repository.createdUsers.map(\.uid).contains(uid)) {
      attempts += 1
      try await Task.sleep(for: .milliseconds(10))
    }
    #expect(await repository.createdUsers.map(\.uid).contains(uid))
  }
}
