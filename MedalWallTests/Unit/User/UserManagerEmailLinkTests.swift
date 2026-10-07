//
//  UserManagerEmailLinkTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-07.
//

import Foundation
import Testing

@testable import MedalWall

@MainActor
struct UserManagerEmailLinkTests {

  private let uid = "uid-new"
  private let email = "runner@example.com"

  // MARK: - Support
  private func makeProfile() -> User {
    User(uid: uid, email: email, firstName: "Mei")
  }

  /// A private defaults suite, optionally holding the email a sign-in link was sent to.
  private func makeDefaults(pendingEmail: String?, function: String = #function) throws
    -> UserDefaults
  {
    let suiteName = "UserManagerEmailLinkTests.\(function).\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defaults.removePersistentDomain(forName: suiteName)
    defaults.set(pendingEmail, forKey: FirebaseAuthService.pendingEmailSignInKey)
    return defaults
  }

  // MARK: - Email sign-in link
  @Test("a sign-in link that signs in clears the saved email and reports nothing")
  func testEmailLinkSignInSucceeds() async throws {
    let authService = StubAuthService(treatsURLsAsSignInLinks: true)
    let defaults = try makeDefaults(pendingEmail: email)
    let manager = UserManager(
      repository: StubUserRepository(), authService: authService,
      networkMonitor: StubNetworkMonitor(), defaults: defaults)
    await authService.report(nil)

    await manager.handleOpenURL(
      try #require(URL(string: "https://medal-wall-4697.firebaseapp.com")))

    #expect(authService.emailLinkSignInEmails == [email])
    #expect(manager.signInError == nil)
    #expect(defaults.string(forKey: FirebaseAuthService.pendingEmailSignInKey) == nil)
  }

  @Test("a sign-in link that fails says so and keeps the saved email for another try")
  func testEmailLinkSignInFailureIsReported() async throws {
    let authService = StubAuthService(
      treatsURLsAsSignInLinks: true, emailLinkOutcome: .failure(.unknown))
    let defaults = try makeDefaults(pendingEmail: email)
    let manager = UserManager(
      repository: StubUserRepository(), authService: authService,
      networkMonitor: StubNetworkMonitor(), defaults: defaults)
    await authService.report(nil)

    await manager.handleOpenURL(
      try #require(URL(string: "https://medal-wall-4697.firebaseapp.com")))

    #expect(manager.signInError == .emailLinkSignInFailed)
    #expect(defaults.string(forKey: FirebaseAuthService.pendingEmailSignInKey) == email)
  }

  @Test("a sign-in link opened where it wasn't requested says so")
  func testEmailLinkFromAnotherDeviceIsReported() async throws {
    let authService = StubAuthService(treatsURLsAsSignInLinks: true)
    let manager = UserManager(
      repository: StubUserRepository(), authService: authService,
      networkMonitor: StubNetworkMonitor(), defaults: try makeDefaults(pendingEmail: nil))
    await authService.report(nil)

    await manager.handleOpenURL(
      try #require(URL(string: "https://medal-wall-4697.firebaseapp.com")))

    #expect(manager.signInError == .emailLinkFromAnotherDevice)
    #expect(authService.emailLinkSignInEmails.isEmpty)
  }

  @Test(
    "a sign-in link opened while signed in is ignored",
    arguments: [nil, "runner@example.com"] as [String?]
  )
  func testEmailLinkWhileSignedInIsIgnored(pendingEmail: String?) async throws {
    let authService = StubAuthService(treatsURLsAsSignInLinks: true)
    let manager = UserManager(
      repository: StubUserRepository(user: makeProfile()), authService: authService,
      networkMonitor: StubNetworkMonitor(), defaults: try makeDefaults(pendingEmail: pendingEmail))
    await authService.report((uid: uid, email: email))

    await manager.handleOpenURL(
      try #require(URL(string: "https://medal-wall-4697.firebaseapp.com")))

    #expect(manager.signInError == nil)
    #expect(authService.emailLinkSignInEmails.isEmpty)
  }

  @Test("a link that opens the app is not used once a saved session is restored")
  func testEarlyLinkIsDroppedBySavedSession() async throws {
    let authService = StubAuthService(treatsURLsAsSignInLinks: true)
    let manager = UserManager(
      repository: StubUserRepository(user: makeProfile()), authService: authService,
      networkMonitor: StubNetworkMonitor(), defaults: try makeDefaults(pendingEmail: email))

    await manager.handleOpenURL(
      try #require(URL(string: "https://medal-wall-4697.firebaseapp.com")))
    await authService.report((uid: uid, email: email))

    #expect(authService.emailLinkSignInEmails.isEmpty)
    #expect(manager.signInError == nil)
  }

  @Test("a link that opens the app signs in once the session turns out signed out")
  func testEarlyLinkIsUsedWhenSignedOut() async throws {
    let authService = StubAuthService(treatsURLsAsSignInLinks: true)
    let manager = UserManager(
      repository: StubUserRepository(), authService: authService,
      networkMonitor: StubNetworkMonitor(), defaults: try makeDefaults(pendingEmail: email))

    await manager.handleOpenURL(
      try #require(URL(string: "https://medal-wall-4697.firebaseapp.com")))
    #expect(authService.emailLinkSignInEmails.isEmpty)
    await authService.report(nil)

    #expect(authService.emailLinkSignInEmails == [email])
  }

  @Test("signing in any way forgets the email a link was sent to")
  func testSignInClearsSavedEmail() async throws {
    let authService = StubAuthService(treatsURLsAsSignInLinks: true)
    let defaults = try makeDefaults(pendingEmail: email)
    let manager = UserManager(
      repository: StubUserRepository(user: makeProfile()), authService: authService,
      networkMonitor: StubNetworkMonitor(), defaults: defaults)

    await authService.report((uid: uid, email: email))

    #expect(defaults.string(forKey: FirebaseAuthService.pendingEmailSignInKey) == nil)
    await authService.report(nil)
    await manager.handleOpenURL(
      try #require(URL(string: "https://medal-wall-4697.firebaseapp.com")))
    #expect(authService.emailLinkSignInEmails.isEmpty)
    #expect(manager.signInError == .emailLinkFromAnotherDevice)
  }

  @Test("a link error from before the session was known is dropped once it turns out signed in")
  func testEarlyLinkErrorIsDroppedBySignIn() async throws {
    let authService = StubAuthService(treatsURLsAsSignInLinks: true)
    let manager = UserManager(
      repository: StubUserRepository(user: makeProfile()), authService: authService,
      networkMonitor: StubNetworkMonitor(), defaults: try makeDefaults(pendingEmail: nil))

    await manager.handleOpenURL(
      try #require(URL(string: "https://medal-wall-4697.firebaseapp.com")))
    await authService.report((uid: uid, email: email))

    #expect(manager.signInError == nil)
  }
}
