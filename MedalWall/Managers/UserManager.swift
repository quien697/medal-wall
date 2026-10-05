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
  private let storageService = StorageService()
  private(set) var currentUserID: String?
  private(set) var currentUser: User?
  private(set) var isLoadingAuth = true

  // MARK: - Computed
  /// Which root screen the app shows.
  var sessionState: SessionState {
    if isLoadingAuth { return .loading }
    return currentUserID == nil ? .signedOut : .ready
  }

  // MARK: - Init
  init(repository: (any UserRepository)? = nil, authService: (any AuthService)? = nil) {
    self.repository = repository ?? UserFirestoreRepository()
    self.authService = authService ?? FirebaseAuthService()
    self.authService.observeAuthState { [weak self] account in
      await self?.authStateDidChange(account)
    }
  }

  // MARK: - Functions
  /// Validates the current Firebase session, signing out if the token is invalid.
  func validateSession() async {
    await authService.validateSession()
  }

  /// Completes a sign-in from a URL the app was opened with — a Google Sign-In redirect or
  /// a Firebase email sign-in link.
  func handleOpenURL(_ url: URL) async {
    authService.handleGoogleSignInURL(url)
    guard authService.isSignInLink(url) else { return }

    await handleEmailLink(url.absoluteString)
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

  /// Follows a sign-in or sign-out reported by `authService`.
  private func authStateDidChange(_ account: (uid: String, email: String?)?) async {
    currentUserID = account?.uid
    if let account {
      currentUser = await loadOrFetchUser(uid: account.uid, email: account.email)
    } else {
      currentUser = nil
    }
    isLoadingAuth = false
  }

  /// Returns the Firestore profile for the signed-in user, creating one if it doesn't exist yet.
  func loadOrFetchUser(uid: String, email: String?) async -> User {
    do {
      if let existing = try await repository.fetchUser(uid: uid) {
        return existing
      }
      let newUser = User(uid: uid, email: email)
      try await repository.createUser(newUser)
      return newUser
    } catch {
      return User(uid: uid, email: email)
    }
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
    case ready
  }
}
