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
  private let modelContext: ModelContext
  private(set) var currentUser: User?
  
  init(modelContext: ModelContext) {
    self.modelContext = modelContext
    loadUser()
  }
  
  /// Loads existing user (created by DefaultDataSeeder)
  private func loadUser() {
    let descriptor = FetchDescriptor<User>()
    if let user = try? modelContext.fetch(descriptor).first {
      self.currentUser = user
    } else {
      // This should never happen if DefaultDataSeeder works
      fatalError("No user found. DefaultDataSeeder may have failed.")
    }
  }
  
  /// Updates the current user (called from settings/profile edit)
  func updateUser(_ user: User) {
    self.currentUser = user
    try? modelContext.save()
  }
}

extension UserManager {
  var currentUserID: UUID? { currentUser?.id }
  var userName: String { currentUser?.fullName ?? "Runner" }
  var isGuest: Bool { currentUser?.isGuest ?? true }
}
