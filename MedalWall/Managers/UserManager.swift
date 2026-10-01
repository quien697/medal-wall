//
//  UserManager.swift
//  MedalWall
//
//  Created by Quien on 2026-03-07.
//

import FirebaseAuth
import SwiftUI

@Observable
class UserManager {
  // MARK: - Properties
  private let repository: any UserRepository
  private let authService = AuthService()
  private let storageService = StorageService()
  private var firebaseUser: FirebaseAuth.User?
  private(set) var currentUser: User?
  private(set) var isLoadingAuth = true

  // MARK: - Computed
  var isLoggedIn: Bool { firebaseUser != nil }

  // MARK: - Init
  init(repository: (any UserRepository)? = nil) {
    self.repository = repository ?? UserFirestoreRepository()
    addAuthListener()
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
    guard let email = UserDefaults.standard.string(forKey: AuthService.pendingEmailSignInKey) else {
      return
    }
    do {
      try await authService.signInWithEmailLink(email: email, link: link)
      UserDefaults.standard.removeObject(forKey: AuthService.pendingEmailSignInKey)
    } catch {}
  }

  /// Registers a Firebase Auth state listener; called once on init.
  private func addAuthListener() {
    _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
      Task { [weak self] in
        guard let self else { return }
        self.firebaseUser = user
        if let user {
          self.currentUser = await self.loadOrFetchUser(uid: user.uid, email: user.email)
        } else {
          self.currentUser = nil
        }
        self.isLoadingAuth = false
      }
    }
  }

  /// Returns the Firestore profile for the signed-in user, creating one if it doesn't exist yet.
  ///
  /// The create is not awaited. The launch gate waits on this, and a write waits for the
  /// server, so a connection lost at first sign-in would otherwise hold the app on its loading
  /// screen. The new profile is used locally meanwhile, as it is when the lookup fails.
  func loadOrFetchUser(uid: String, email: String?) async -> User {
    do {
      if let existing = try await repository.fetchUser(uid: uid) {
        return existing
      }
      let newUser = User(uid: uid, email: email)
      Task { [repository] in
        try? await repository.createUser(newUser)
      }
      return newUser
    } catch {
      return User(uid: uid, email: email)
    }
  }
}

// MARK: - Convenience
extension UserManager {
  var currentUserID: String? { firebaseUser?.uid }
  var currentUserName: String { currentUser?.name ?? .appLocalized("Runner") }
}
