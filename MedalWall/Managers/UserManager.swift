//
//  UserManager.swift
//  MedalWall
//
//  Created by Quien on 2026-03-07.
//

import SwiftUI
import SwiftData

@Observable
class UserManager {
  private let repository: UserRepository
  private(set) var currentUser: User?
  
  init(modelContext: ModelContext) {
    self.repository = UserRepository(context: modelContext)
    loadUser()
  }
  
  /// Loads existing user (created by DefaultDataSeeder)
  private func loadUser() {
    if let user = try? repository.getUser() {
      self.currentUser = user
    } else {
      // This should never happen if DefaultDataSeeder works
      fatalError("No user found. DefaultDataSeeder may have failed.")
    }
  }
  
  /// Updates the current user (called from settings/profile edit)
  func updateUser(_ user: User) {
    self.currentUser = user
  }
}

extension UserManager {
  var currentUserID: UUID? { currentUser?.id }
  var userName: String { currentUser?.fullName ?? "Runner" }
  var isGuest: Bool { currentUser?.isGuest ?? true }
}
