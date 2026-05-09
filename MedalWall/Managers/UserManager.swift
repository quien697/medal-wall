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
  private let context: ModelContext
  private let authService = AuthService()
  private(set) var firebaseUser: FirebaseAuth.User?
  private(set) var currentUser: User?
  private(set) var isLoadingAuth = true

  // MARK: - Computed
  var currentAppUser: AppUser? { firebaseUser.map { AppUser(firebaseUser: $0) } }
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

  /// Updates the local SwiftData user reference, e.g. after an edit.
  func updateUser(_ user: User) {
    self.currentUser = user
  }

  // MARK: - Private

  private func addAuthListener() {
    _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
      Task { [weak self] in
        guard let self else { return }
        self.firebaseUser = user
        if user != nil {
          self.loadUser()
        } else {
          self.currentUser = nil
        }
        self.isLoadingAuth = false
      }
    }
  }

  private func loadUser() {
    self.currentUser = try? repository.getUser()
  }
}

// MARK: - Convenience
extension UserManager {
  var currentUserID: UUID? { currentUser?.id }
  var userName: String { currentAppUser?.displayName ?? "Runner" }
}
