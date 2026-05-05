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
  private let repository: UserRepository
  private let context: ModelContext
  private let authService = AuthService()
  private(set) var currentUser: User?
  private(set) var firebaseUser: FirebaseAuth.User?
  
  var isLoggedIn: Bool { firebaseUser != nil || currentUser != nil }
  
  init(modelContext: ModelContext) {
    self.context = modelContext
    self.repository = UserRepository(context: modelContext)
    loadUser()
    addAuthListener()
  }
  
  private func addAuthListener() {
    _ = Auth.auth().addStateDidChangeListener { [weak self] _, user in
      Task { [weak self] in
        self?.firebaseUser = user
      }
    }
  }
  
  func validateSession() async {
    await authService.validateSession()
  }

  func handleEmailLink(_ link: String) async {
    guard let email = UserDefaults.standard.string(forKey: AuthService.pendingEmailSignInKey) else { return }

    do {
      try await authService.signInWithEmailLink(email: email, link: link)
      UserDefaults.standard.removeObject(forKey: AuthService.pendingEmailSignInKey)
    } catch {
      // sign-in failure surfaces through the auth state listener
    }
  }
  
  func signOut() throws {
    try authService.signOut()
  }
  
  private func loadUser() {
    if let user = try? repository.getUser() {
      self.currentUser = user
    }
  }
  
  func updateUser(_ user: User) {
    self.currentUser = user
  }
  
  func startAsGuest() throws {
    try DefaultDataSeeder.seed(in: context)
    loadUser()
  }
}

extension UserManager {
  var currentUserID: UUID? { currentUser?.id }
  var userName: String { currentUser?.fullName ?? "Runner" }
  var isGuest: Bool { currentUser?.isGuest ?? true }
}
