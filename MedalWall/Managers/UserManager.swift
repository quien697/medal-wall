//
//  UserManager.swift
//  MedalWall
//
//  Created by Quien on 2026-03-07.
//

import SwiftUI

@Observable
class UserManager {
  // MARK: - Properties
  private let repository: any UserRepository
  private let authService: any AuthService
  private let networkMonitor: any NetworkMonitor
  private let storageService = StorageService()
  private var currentUserEmail: String?
  /// Why the profile could not load; nil while it is loading or once it has.
  private var profileLoadError: AppError?
  private var isConnected = true
  private(set) var currentUserID: String?
  private(set) var currentUser: User?
  private(set) var isLoadingAuth = true

  // MARK: - Computed
  /// Which root screen the app shows. A signed-in user reaches the app only once their
  /// profile has loaded.
  var sessionState: SessionState {
    if isLoadingAuth { return .loading }
    guard currentUserID != nil else { return .signedOut }
    if currentUser != nil { return .ready }
    if profileLoadError == .noInternetConnection || !isConnected { return .waitingForConnection }
    return profileLoadError == nil ? .loading : .profileUnavailable
  }

  // MARK: - Init
  init(
    repository: (any UserRepository)? = nil,
    authService: (any AuthService)? = nil,
    networkMonitor: (any NetworkMonitor)? = nil
  ) {
    self.repository = repository ?? UserFirestoreRepository()
    self.authService = authService ?? FirebaseAuthService()
    self.networkMonitor = networkMonitor ?? NWPathNetworkMonitor()
    self.authService.observeAuthState { [weak self] account in
      await self?.authStateDidChange(account)
    }
    self.networkMonitor.observe { [weak self] isConnected in
      await self?.connectivityDidChange(isConnected)
    }
  }

  // MARK: - Functions
  /// Validates the current Firebase session, signing out if the token is invalid, and
  /// tries again to load a profile that couldn't load.
  func validateSession() async {
    await authService.validateSession()
    await reloadProfileIfFailed()
  }

  /// Completes a sign-in from a URL the app was opened with — a Google Sign-In redirect or
  /// a Firebase email sign-in link.
  func handleOpenURL(_ url: URL) async {
    authService.handleGoogleSignInURL(url)
    guard authService.isSignInLink(url) else { return }

    await handleEmailLink(url.absoluteString)
  }

  /// Tries again to load a profile that failed to load.
  func retryProfileLoad() async {
    await loadProfile()
  }

  /// Signs the current user out of Firebase.
  func signOut() throws {
    try authService.signOut()
  }

  /// Persists an updated profile to Firestore, uploading a new photo to Storage first if provided,
  /// or deleting the existing one if the photo was cleared.
  func updateUser(_ user: User, photo: UIImage? = nil) async throws {
    var updatedUser = user
    if let photo {
      updatedUser.photoUrl = try await storageService.uploadUserAvatar(uid: user.uid, image: photo)
    } else if user.photoUrl == nil, currentUser?.photoUrl != nil {
      try? await storageService.deleteUserAvatar(uid: user.uid)
    }
    try await repository.updateUser(updatedUser)
    self.currentUser = updatedUser
  }

  /// Ratchets the user's persisted milestone counts upward based on live medal
  /// counts, never decreasing an already-earned tier. Call after a medal is
  /// created or edited; never after a delete.
  func refreshAchievementMilestones(medals: [Medal]) async {
    guard let user = currentUser else { return }

    let newFullMilestone = AchievementProgress.ratchetedMilestone(
      persisted: user.highestFullMilestone ?? 0,
      liveCount: medals.fullCount
    )
    let newHalfMilestone = AchievementProgress.ratchetedMilestone(
      persisted: user.highestHalfMilestone ?? 0,
      liveCount: medals.halfCount
    )

    guard
      newFullMilestone != (user.highestFullMilestone ?? 0)
        || newHalfMilestone != (user.highestHalfMilestone ?? 0)
    else { return }

    var updated = user
    updated.highestFullMilestone = newFullMilestone
    updated.highestHalfMilestone = newHalfMilestone

    do {
      try await repository.updateUser(updated)
      self.currentUser = updated
    } catch {}
  }

  // MARK: - Private Functions
  /// Completes an email link sign-in using the URL opened by the user.
  private func handleEmailLink(_ link: String) async {
    guard
      let email = UserDefaults.standard.string(forKey: FirebaseAuthService.pendingEmailSignInKey)
    else {
      return
    }
    do {
      try await authService.signInWithEmailLink(email: email, link: link)
      UserDefaults.standard.removeObject(forKey: FirebaseAuthService.pendingEmailSignInKey)
    } catch {}
  }

  /// Follows a sign-in or sign-out reported by `authService`, then loads the new account's
  /// profile.
  private func authStateDidChange(_ account: (uid: String, email: String?)?) async {
    currentUserID = account?.uid
    currentUserEmail = account?.email
    currentUser = nil
    profileLoadError = nil
    isLoadingAuth = false
    guard account != nil else { return }

    await loadProfile()
  }

  /// Loads the signed-in user's profile, creating it on first sign-in. When it can't load,
  /// no profile stands in for it: `currentUser` stays nil and `profileLoadError` says why.
  private func loadProfile() async {
    guard let uid = currentUserID else { return }

    profileLoadError = nil
    do {
      if let existing = try await repository.fetchUser(uid: uid) {
        currentUser = existing
      } else {
        let newUser = User(uid: uid, email: currentUserEmail)
        try await repository.createUser(newUser)
        currentUser = newUser
      }
    } catch {
      profileLoadError = error as? AppError ?? .unknown
    }
  }

  /// Records whether the device is online, and retries a profile that couldn't load once it is.
  private func connectivityDidChange(_ isConnected: Bool) async {
    self.isConnected = isConnected
    guard isConnected else { return }

    await reloadProfileIfFailed()
  }

  /// Loads the profile again if the last attempt failed.
  private func reloadProfileIfFailed() async {
    guard currentUser == nil, profileLoadError != nil else { return }

    await loadProfile()
  }
}

// MARK: - Convenience
extension UserManager {
  var currentUserName: String { currentUser?.name ?? .appLocalized("Runner") }
}

// MARK: - SessionState
extension UserManager {
  /// The root screens the app moves between as the session and profile load.
  enum SessionState {
    case loading
    case signedOut
    case waitingForConnection
    case profileUnavailable
    case ready
  }
}
