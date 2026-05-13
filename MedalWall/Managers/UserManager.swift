//
//  UserManager.swift
//  MedalWall
//
//  Created by Quien on 2026-03-07.
//

import SwiftUI
import FirebaseAuth

@Observable
class UserManager {
  // MARK: - Properties
  private let repository = UserFirestoreRepository()
  private let authService = AuthService()
  private let storageService = StorageService()
  private var firebaseUser: FirebaseAuth.User?
  private(set) var currentUser: User?
  private(set) var isLoadingAuth = true
  
  // MARK: - Computed
  var isLoggedIn: Bool { firebaseUser != nil }
  
  // MARK: - Init
  init() {
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
  
  /// Persists an updated profile to Firestore, uploading a new photo to Storage first if provided.
  func updateUser(_ user: User, photo: UIImage? = nil) async throws {
    var updatedUser = user
    if let photo {
      updatedUser.photoUrl = try await storageService.uploadUserAvatar(uid: user.uid, image: photo)
    }
    try await repository.updateUser(updatedUser)
    self.currentUser = updatedUser
  }
  
  // MARK: - Private Functions
  
  /// Registers a Firebase Auth state listener; called once on init.
  private func addAuthListener() {
    _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
      Task { [weak self] in
        guard let self else { return }
        self.firebaseUser = user
        if let user {
          await self.loadOrFetchUser(firebaseUser: user)
        } else {
          self.currentUser = nil
        }
        self.isLoadingAuth = false
      }
    }
  }
  
  /// Loads the Firestore profile for the signed-in user, or creates one if it doesn't exist yet.
  private func loadOrFetchUser(firebaseUser: FirebaseAuth.User) async {
    do {
      if let existing = try await repository.fetchUser(uid: firebaseUser.uid) {
        self.currentUser = existing
      } else {
        let newUser = User(firebaseUser: firebaseUser)
        try await repository.createUser(newUser)
        self.currentUser = newUser
      }
    } catch {
      self.currentUser = User(firebaseUser: firebaseUser)
    }
  }
}

// MARK: - Convenience
extension UserManager {
  var currentUserID: String? { firebaseUser?.uid }
  var currentUserName: String { currentUser?.name ?? "Runner" }
}
