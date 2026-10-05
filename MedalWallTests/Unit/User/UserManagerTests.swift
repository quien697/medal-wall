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

  // MARK: - Support
  private func makeProfile() -> User {
    User(uid: uid, email: email, firstName: "Mei")
  }

  // MARK: - First sign-in
  @Test("a first sign-in writes the new profile before it returns")
  func testFirstSignInWritesProfile() async {
    let repository = StubUserRepository(createLatency: .milliseconds(200))
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor())

    await authService.report((uid: uid, email: email))

    #expect(manager.currentUser?.email == email)
    #expect(await repository.createdUsers.map(\.uid) == [uid])
  }

  @Test("signing in shows the loading screen until the new profile is created")
  func testSignInWaitsForProfileCreate() async throws {
    let repository = StubUserRepository(createLatency: .milliseconds(300))
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor())
    await authService.report(nil)

    let signIn = Task { await authService.report((uid: uid, email: email)) }
    try await Task.sleep(for: .milliseconds(100))

    #expect(manager.sessionState == .loading)
    await signIn.value
    #expect(manager.sessionState == .ready)
  }

  @Test("a new profile still waiting for the server while offline shows waiting for a connection")
  func testPendingCreateOfflineWaitsForConnection() async throws {
    let repository = StubUserRepository(createLatency: .milliseconds(300))
    let authService = StubAuthService()
    let networkMonitor = StubNetworkMonitor()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: networkMonitor)
    await authService.report(nil)
    await networkMonitor.report(isConnected: false)

    let signIn = Task { await authService.report((uid: uid, email: email)) }
    try await Task.sleep(for: .milliseconds(100))

    #expect(manager.sessionState == .waitingForConnection)
    await signIn.value
  }

  // MARK: - Profile that can't load
  @Test("a profile that can't load offline leaves no blank profile and waits for a connection")
  func testOfflineLoadWaitsForConnection() async {
    let repository = StubUserRepository(
      user: makeProfile(), fetchOutcome: .failure(.noInternetConnection))
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor())

    await authService.report((uid: uid, email: email))

    #expect(manager.currentUser == nil)
    #expect(manager.sessionState == .waitingForConnection)
    #expect(await repository.createdUsers.isEmpty)
  }

  @Test("a profile that can't load for another reason shows that it can't load")
  func testFailedLoadIsUnavailable() async {
    let repository = StubUserRepository(user: makeProfile(), fetchOutcome: .failure(.unknown))
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor())

    await authService.report((uid: uid, email: email))

    #expect(manager.currentUser == nil)
    #expect(manager.sessionState == .profileUnavailable)
  }

  @Test("the profile loads when the connection returns")
  func testReconnectLoadsProfile() async {
    let repository = StubUserRepository(
      user: makeProfile(), fetchOutcome: .failure(.noInternetConnection))
    let authService = StubAuthService()
    let networkMonitor = StubNetworkMonitor()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: networkMonitor)
    await networkMonitor.report(isConnected: false)
    await authService.report((uid: uid, email: email))

    await repository.setFetchOutcome(.success(()))
    await networkMonitor.report(isConnected: true)

    #expect(manager.sessionState == .ready)
    #expect(manager.currentUser?.firstName == "Mei")
  }

  @Test("coming back to the app retries a profile that couldn't load")
  func testForegroundRetriesProfile() async {
    let repository = StubUserRepository(
      user: makeProfile(), fetchOutcome: .failure(.noInternetConnection))
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor())
    await authService.report((uid: uid, email: email))

    await repository.setFetchOutcome(.success(()))
    await manager.validateSession()

    #expect(manager.sessionState == .ready)
  }

  @Test("Retry loads a profile that failed to load")
  func testRetryLoadsProfile() async {
    let repository = StubUserRepository(user: makeProfile(), fetchOutcome: .failure(.unknown))
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor())
    await authService.report((uid: uid, email: email))

    await repository.setFetchOutcome(.success(()))
    await manager.retryProfileLoad()

    #expect(manager.sessionState == .ready)
    #expect(manager.currentUser?.firstName == "Mei")
  }
}
