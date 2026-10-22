//
//  UserManagerTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-30.
//

import Foundation
import Testing
import UIKit

@testable import MedalWall

@MainActor
struct UserManagerTests {

  private let uid = "uid-new"
  private let email = "runner@example.com"
  /// A private defaults suite per test, so a simulated sign-in never clears the email a real
  /// sign-in link was sent to in the app's own defaults.
  private let defaults: UserDefaults

  init() throws {
    let suiteName = "UserManagerTests.\(UUID().uuidString)"
    defaults = try #require(UserDefaults(suiteName: suiteName))
    defaults.removePersistentDomain(forName: suiteName)
  }

  // MARK: - Support
  private func makeProfile(photoUrl: String? = nil) -> User {
    User(uid: uid, email: email, firstName: "Mei", photoUrl: photoUrl)
  }

  // MARK: - First sign-in
  @Test("a first sign-in writes the new profile before it returns")
  func testFirstSignInWritesProfile() async {
    let repository = StubUserRepository(createLatency: .milliseconds(200))
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: defaults)

    await authService.report((uid: uid, email: email))

    #expect(manager.currentUser?.email == email)
    #expect(await repository.createdUsers.map(\.uid) == [uid])
  }

  @Test("the app is loading before anyone is known to be signed in")
  func testLaunchIsLoading() {
    let manager = UserManager(
      repository: StubUserRepository(), authService: StubAuthService(),
      networkMonitor: StubNetworkMonitor(), defaults: defaults)

    #expect(manager.sessionState == .loading)
  }

  @Test(
    "signing in opens the tabs while the new profile is still being created",
    .timeLimit(.minutes(1)))
  func testSignInOpensTabsBeforeProfile() async throws {
    let repository = StubUserRepository(holdsCreates: true)
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: defaults)
    await authService.report(nil)

    let signIn = Task { await authService.report((uid: uid, email: email)) }
    await repository.waitForCreateToStart()

    #expect(manager.sessionState == .ready)
    #expect(manager.currentUser == nil)
    await repository.releaseCreate()
    await signIn.value
    #expect(manager.currentUser?.uid == uid)
  }

  @Test("a profile that finishes loading after sign-out is dropped", .timeLimit(.minutes(1)))
  func testProfileLoadedAfterSignOutIsDropped() async throws {
    let repository = StubUserRepository(holdsCreates: true)
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: defaults)
    let signIn = Task { await authService.report((uid: uid, email: email)) }
    await repository.waitForCreateToStart()

    await authService.report(nil)
    await repository.releaseCreate()
    await signIn.value

    #expect(manager.currentUser == nil)
    #expect(manager.sessionState == .signedOut)
  }

  // MARK: - Profile that can't load
  @Test(
    "a profile that can't load leaves no blank profile and still opens the tabs",
    arguments: [AppError.noInternetConnection, .unknown]
  )
  func testFailedLoadOpensTabs(error: AppError) async {
    let repository = StubUserRepository(user: makeProfile(), fetchOutcome: .failure(error))
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: defaults)

    await authService.report((uid: uid, email: email))

    #expect(manager.currentUser == nil)
    #expect(manager.sessionState == .ready)
    #expect(await repository.createdUsers.isEmpty)
  }

  @Test("the profile loads when the connection returns")
  func testReconnectLoadsProfile() async {
    let repository = StubUserRepository(
      user: makeProfile(), fetchOutcome: .failure(.noInternetConnection))
    let authService = StubAuthService()
    let networkMonitor = StubNetworkMonitor()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: networkMonitor,
      defaults: defaults)
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
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: defaults)
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
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: defaults)

    await authService.report((uid: uid, email: email))

    #expect(manager.sessionState == .ready)
    #expect(!manager.canEditProfile)
  }

  @Test("a profile from the server can be edited")
  func testServerProfileIsEditable() async {
    let repository = StubUserRepository(user: makeProfile())
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: defaults)

    await authService.report((uid: uid, email: email))

    #expect(manager.canEditProfile)
  }

  @Test("the server's profile replaces the phone's copy when the connection returns")
  func testReconnectReplacesCachedProfile() async {
    let repository = StubUserRepository(user: makeProfile(), fetchesFromCache: true)
    let authService = StubAuthService()
    let networkMonitor = StubNetworkMonitor()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: networkMonitor,
      defaults: defaults)
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
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: defaults)
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
      networkMonitor: StubNetworkMonitor(), storageService: storage, defaults: defaults)
    await authService.report((uid: uid, email: email))
    var edited = try #require(manager.currentUser)
    edited.photoUrl = nil

    try await manager.updateUser(edited)

    #expect(await storage.deletedURLs == ["https://example.com/avatar.jpg"])
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
      networkMonitor: StubNetworkMonitor(), storageService: storage, defaults: defaults)
    await authService.report((uid: uid, email: email))
    var edited = try #require(manager.currentUser)
    edited.photoUrl = nil

    await #expect(throws: AppError.userSaveFailed) {
      try await manager.updateUser(edited)
    }

    #expect(await storage.deletedURLs.isEmpty)
    #expect(manager.currentUser?.photoUrl == "https://example.com/avatar.jpg")
  }

  @Test("a replaced profile photo is deleted once the profile saves")
  func testReplacedPhotoIsDeletedAfterSave() async throws {
    let repository = StubUserRepository(
      user: makeProfile(photoUrl: "https://example.com/avatar.jpg"))
    let storage = StubPhotoStorage()
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService,
      networkMonitor: StubNetworkMonitor(), storageService: storage, defaults: defaults)
    await authService.report((uid: uid, email: email))
    let edited = try #require(manager.currentUser)

    try await manager.updateUser(edited, photo: UIImage())

    #expect(await storage.deletedURLs == ["https://example.com/avatar.jpg"])
    #expect(await storage.deletedOwners == [.user(uid: uid)])
    #expect(manager.currentUser?.photoUrl == "https://example.com/uploaded.jpg")
  }

  @Test("a replaced profile photo is kept and the new upload deleted when the save fails")
  func testReplacedPhotoIsKeptWhenSaveFails() async throws {
    let repository = StubUserRepository(
      user: makeProfile(photoUrl: "https://example.com/avatar.jpg"),
      writeOutcome: .failure(.userSaveFailed))
    let storage = StubPhotoStorage()
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService,
      networkMonitor: StubNetworkMonitor(), storageService: storage, defaults: defaults)
    await authService.report((uid: uid, email: email))
    let edited = try #require(manager.currentUser)

    await #expect(throws: AppError.userSaveFailed) {
      try await manager.updateUser(edited, photo: UIImage())
    }

    #expect(await storage.deletedURLs == ["https://example.com/uploaded.jpg"])
    #expect(manager.currentUser?.photoUrl == "https://example.com/avatar.jpg")
  }

  // MARK: - Sign out
  @Test(
    "signing out ends the session and returns to the login screen, online or offline",
    arguments: [true, false]
  )
  func testSignOutReturnsToLogin(isConnected: Bool) async throws {
    let authService = StubAuthService()
    let networkMonitor = StubNetworkMonitor()
    networkMonitor.isConnectedNow = isConnected
    let manager = UserManager(
      repository: StubUserRepository(user: makeProfile()), authService: authService,
      networkMonitor: networkMonitor, defaults: defaults)
    await authService.report((uid: uid, email: email))

    try manager.signOut()
    await authService.report(nil)

    #expect(authService.signOutCount == 1)
    #expect(manager.sessionState == .signedOut)
    #expect(manager.currentUser == nil)
  }
}

// MARK: - Profile load state
extension UserManagerTests {
  @Test("a signed-in profile counts as loading until it arrives", .timeLimit(.minutes(1)))
  func testProfileLoadingUntilItArrives() async {
    let repository = StubUserRepository(user: makeProfile())
    await repository.fetchHold.holdNext()
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: defaults)

    let signIn = Task { await authService.report((uid: uid, email: email)) }
    await repository.fetchHold.waitForStart()

    #expect(manager.isProfileLoading)
    await repository.fetchHold.release()
    await signIn.value
    #expect(!manager.isProfileLoading)
    #expect(manager.currentUser != nil)
  }

  @Test("a profile that can't load stops counting as loading and says why")
  func testFailedLoadSaysWhy() async {
    let repository = StubUserRepository(
      user: makeProfile(), fetchOutcome: .failure(.noInternetConnection))
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: defaults)

    await authService.report((uid: uid, email: email))

    #expect(!manager.isProfileLoading)
    #expect(manager.profileLoadError == .noInternetConnection)
  }

  @Test(
    "retrying a profile that couldn't load counts as loading again", .timeLimit(.minutes(1)))
  func testRetryCountsAsLoading() async {
    let repository = StubUserRepository(
      user: makeProfile(), fetchOutcome: .failure(.noInternetConnection))
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: defaults)
    await authService.report((uid: uid, email: email))
    await repository.setFetchOutcome(.success(()))
    await repository.fetchHold.holdNext()

    let retry = Task { await manager.validateSession() }
    await repository.fetchHold.waitForStart()

    #expect(manager.isProfileLoading)
    #expect(manager.profileLoadError == nil)
    await repository.fetchHold.release()
    await retry.value
    #expect(!manager.isProfileLoading)
    #expect(manager.profileLoadError == nil)
    #expect(manager.currentUser?.firstName == "Mei")
  }

  @Test("nobody signed in means no profile to load")
  func testSignedOutIsNotLoading() async {
    let authService = StubAuthService()
    let manager = UserManager(
      repository: StubUserRepository(), authService: authService,
      networkMonitor: StubNetworkMonitor(), defaults: defaults)

    await authService.report(nil)

    #expect(!manager.isProfileLoading)
  }

  // MARK: - Displayed profile
  @Test(
    "while the profile loads the header shows the placeholder user, as bones",
    .timeLimit(.minutes(1)))
  func testDisplayedUserIsPlaceholderWhileLoading() async {
    let repository = StubUserRepository(user: makeProfile())
    await repository.fetchHold.holdNext()
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: defaults)

    let signIn = Task { await authService.report((uid: uid, email: email)) }
    await repository.fetchHold.waitForStart()

    #expect(manager.displayedUser?.uid == User.placeholder.uid)
    #expect(!manager.isProfileUnavailable)
    await repository.fetchHold.release()
    await signIn.value
    #expect(manager.displayedUser?.firstName == "Mei")
  }

  @Test("a profile that can't load is unavailable, and no user is shown")
  func testFailedProfileIsUnavailable() async {
    let repository = StubUserRepository(
      user: makeProfile(), fetchOutcome: .failure(.noInternetConnection))
    let authService = StubAuthService()
    let manager = UserManager(
      repository: repository, authService: authService, networkMonitor: StubNetworkMonitor(),
      defaults: defaults)

    await authService.report((uid: uid, email: email))

    #expect(manager.isProfileUnavailable)
    #expect(manager.displayedUser == nil)
  }

  @Test("nobody signed in shows no user, not the placeholder")
  func testSignedOutShowsNoUser() async {
    let authService = StubAuthService()
    let manager = UserManager(
      repository: StubUserRepository(), authService: authService,
      networkMonitor: StubNetworkMonitor(), defaults: defaults)

    await authService.report(nil)

    #expect(manager.displayedUser == nil)
    #expect(!manager.isProfileUnavailable)
  }
}
