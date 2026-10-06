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
  private func makeProfile(photoUrl: String? = nil) -> User {
    User(uid: uid, email: email, firstName: "Mei", photoUrl: photoUrl)
  }

  /// A private defaults suite, optionally holding the email a sign-in link was sent to.
  private func makeDefaults(pendingEmail: String?, function: String = #function) throws
    -> UserDefaults
  {
    let suiteName = "UserManagerTests.\(function).\(UUID().uuidString)"
    let defaults = try #require(UserDefaults(suiteName: suiteName))
    defaults.removePersistentDomain(forName: suiteName)
    defaults.set(pendingEmail, forKey: FirebaseAuthService.pendingEmailSignInKey)
    return defaults
  }

  /// One full-marathon medal: enough to earn the first full-marathon milestone.
  private func makeFullMarathonMedal() -> Medal {
    Medal(
      name: "Taipei Marathon",
      date: .now,
      bibNumber: "1",
      place: Place(countryCode: "TW", city: "Taipei City"),
      distance: RaceDistance(category: .full, type: .inPerson),
      userID: uid
    )
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

  @Test("the app is loading before anyone is known to be signed in")
  func testLaunchIsLoading() {
    let manager = UserManager(
      repository: StubUserRepository(), authService: StubAuthService(),
      networkMonitor: StubNetworkMonitor())

    #expect(manager.sessionState == .loading)
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

  @Test("a profile that finishes loading after sign-out is dropped")
  func testProfileLoadedAfterSignOutIsDropped() async throws {
    let repository = StubUserRepository(createLatency: .milliseconds(300))
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor())
    let signIn = Task { await authService.report((uid: uid, email: email)) }
    try await Task.sleep(for: .milliseconds(100))

    await authService.report(nil)
    await signIn.value

    #expect(manager.currentUser == nil)
    #expect(manager.sessionState == .signedOut)
  }

  // MARK: - Profile that can't load
  @Test(
    "a profile that can't load leaves no blank profile and keeps the loading screen",
    arguments: [AppError.noInternetConnection, .unknown]
  )
  func testFailedLoadKeepsLoading(error: AppError) async {
    let repository = StubUserRepository(user: makeProfile(), fetchOutcome: .failure(error))
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor())

    await authService.report((uid: uid, email: email))

    #expect(manager.currentUser == nil)
    #expect(manager.sessionState == .loading)
    #expect(await repository.createdUsers.isEmpty)
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

  // MARK: - Phone's copy
  @Test("a profile read from the phone's copy opens the app but can't be edited")
  func testCachedProfileIsNotEditable() async {
    let repository = StubUserRepository(user: makeProfile(), fetchesFromCache: true)
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor())

    await authService.report((uid: uid, email: email))

    #expect(manager.sessionState == .ready)
    #expect(!manager.canEditProfile)
  }

  @Test("a profile from the server can be edited")
  func testServerProfileIsEditable() async {
    let repository = StubUserRepository(user: makeProfile())
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor())

    await authService.report((uid: uid, email: email))

    #expect(manager.canEditProfile)
  }

  @Test("milestones are written to a profile from the server")
  func testServerProfileGetsMilestones() async {
    let repository = StubUserRepository(user: makeProfile())
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor())
    await authService.report((uid: uid, email: email))

    await manager.refreshAchievementMilestones(medals: [makeFullMarathonMedal()])

    #expect(await repository.updatedUsers.map(\.highestFullMilestone) == [1])
  }

  @Test("milestones are not written to a profile read from the phone's copy")
  func testCachedProfileSkipsMilestones() async {
    let repository = StubUserRepository(user: makeProfile(), fetchesFromCache: true)
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor())
    await authService.report((uid: uid, email: email))

    await manager.refreshAchievementMilestones(medals: [makeFullMarathonMedal()])

    #expect(await repository.updatedUsers.isEmpty)
  }

  @Test("the server's profile replaces the phone's copy when the connection returns")
  func testReconnectReplacesCachedProfile() async {
    let repository = StubUserRepository(user: makeProfile(), fetchesFromCache: true)
    let authService = StubAuthService()
    let networkMonitor = StubNetworkMonitor()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: networkMonitor)
    await networkMonitor.report(isConnected: false)
    await authService.report((uid: uid, email: email))
    #expect(!manager.canEditProfile)

    await repository.setFetchesFromCache(false)
    await networkMonitor.report(isConnected: true)

    #expect(manager.canEditProfile)
  }

  @Test("coming back to the app replaces the phone's copy with the server's profile")
  func testForegroundReplacesCachedProfile() async {
    let repository = StubUserRepository(user: makeProfile(), fetchesFromCache: true)
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor())
    await authService.report((uid: uid, email: email))
    #expect(!manager.canEditProfile)

    await repository.setFetchesFromCache(false)
    await manager.validateSession()

    #expect(manager.canEditProfile)
  }

  // MARK: - Profile photo
  @Test("a removed profile photo is deleted once the profile saves")
  func testRemovedPhotoIsDeletedAfterSave() async throws {
    let repository = StubUserRepository(
      user: makeProfile(photoUrl: "https://example.com/avatar.jpg"))
    let storage = StubPhotoStorage()
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService,
      networkMonitor: StubNetworkMonitor(), storageService: storage)
    await authService.report((uid: uid, email: email))
    var edited = try #require(manager.currentUser)
    edited.photoUrl = nil

    try await manager.updateUser(edited)

    #expect(await storage.avatarDeleteCount == 1)
    #expect(await repository.updatedUsers.map(\.photoUrl) == [nil])
  }

  @Test("a removed profile photo is kept when the profile save fails")
  func testRemovedPhotoIsKeptWhenSaveFails() async throws {
    let repository = StubUserRepository(
      user: makeProfile(photoUrl: "https://example.com/avatar.jpg"),
      writeOutcome: .failure(.userSaveFailed))
    let storage = StubPhotoStorage()
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService,
      networkMonitor: StubNetworkMonitor(), storageService: storage)
    await authService.report((uid: uid, email: email))
    var edited = try #require(manager.currentUser)
    edited.photoUrl = nil

    await #expect(throws: AppError.userSaveFailed) {
      try await manager.updateUser(edited)
    }

    #expect(await storage.avatarDeleteCount == 0)
    #expect(manager.currentUser?.photoUrl == "https://example.com/avatar.jpg")
  }

  // MARK: - Email sign-in link
  @Test("a sign-in link that signs in clears the saved email and reports nothing")
  func testEmailLinkSignInSucceeds() async throws {
    let authService = StubAuthService(treatsURLsAsSignInLinks: true)
    let defaults = try makeDefaults(pendingEmail: email)
    let manager = UserManager(
      repository: StubUserRepository(), authService: authService,
      networkMonitor: StubNetworkMonitor(), defaults: defaults)

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

    await manager.handleOpenURL(
      try #require(URL(string: "https://medal-wall-4697.firebaseapp.com")))

    #expect(manager.signInError == .emailLinkFromAnotherDevice)
    #expect(authService.emailLinkSignInEmails.isEmpty)
  }
}
