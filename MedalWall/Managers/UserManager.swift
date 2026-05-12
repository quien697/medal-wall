//
//  UserManager.swift
//  MedalWall
//
//  Created by Quien on 2026-03-07.
//

import SwiftUI
import SwiftData
import FirebaseAuth

@Observable
class UserManager {
  // MARK: - Properties
  private let repository: UserRepository
  private let firestoreRepository = UserFirestoreRepository()
  private let context: ModelContext
  private let authService = AuthService()
  private(set) var firebaseUser: FirebaseAuth.User?
  private(set) var currentAppUser: AppUser?
  private(set) var currentUser: User?
  private(set) var isLoadingAuth = true

  // MARK: - Computed
  var isLoggedIn: Bool { firebaseUser != nil }

  // MARK: - Init
  init(modelContext: ModelContext) {
    self.context = modelContext
    self.repository = UserRepository(context: modelContext)
    addAuthListener()
  }

  // MARK: - Functions

  /// Validates the current Firebase session, signing out if the token is invalid.
  func validateSession() async {
    await authService.validateSession()
  }

  /// Completes an email link sign-in using the URL opened by the user.
  func handleEmailLink(_ link: String) async {
    guard let email = UserDefaults.standard.string(forKey: AuthService.pendingEmailSignInKey) else { return }
    do {
      try await authService.signInWithEmailLink(email: email, link: link)
      UserDefaults.standard.removeObject(forKey: AuthService.pendingEmailSignInKey)
    } catch { }
  }

  /// Signs the current user out of Firebase.
  func signOut() throws {
    try authService.signOut()
  }

  /// Persists an updated AppUser to Firestore, uploading a new avatar to Storage if provided.
  func updateAppUser(_ user: AppUser) async throws {
    try await firestoreRepository.updateUser(user)
    self.currentAppUser = user
  }

  /// Updates the local SwiftData user reference, e.g. after a profile edit.
  func updateUser(_ user: User) {
    self.currentUser = user
  }

  // MARK: - Private

  private func addAuthListener() {
    _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
      Task { [weak self] in
        guard let self else { return }
        self.firebaseUser = user
        if let user {
          await self.loadOrFetchUser(firebaseUser: user)
        } else {
          self.currentAppUser = nil
          self.currentUser = nil
        }
        self.isLoadingAuth = false
      }
    }
  }

  private func loadOrFetchUser(firebaseUser: FirebaseAuth.User) async {
    do {
      if let existing = try await firestoreRepository.fetchUser(uid: firebaseUser.uid) {
        self.currentAppUser = existing
      } else {
        let newUser = AppUser(firebaseUser: firebaseUser)
        try await firestoreRepository.createUser(newUser)
        self.currentAppUser = newUser
      }
    } catch {
      self.currentAppUser = AppUser(firebaseUser: firebaseUser)
    }
    self.loadUser()
  }

  private func loadUser() {
    self.currentUser = try? repository.getUser()
  }
}

// MARK: - Convenience
extension UserManager {
  var currentUserID: UUID? { currentUser?.id }
  var currentUserName: String { currentAppUser?.name ?? "Runner" }
}
