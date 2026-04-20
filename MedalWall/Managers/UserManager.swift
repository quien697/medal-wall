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
  private let context: ModelContext
  private(set) var currentUser: User?
  
  init(modelContext: ModelContext) {
    self.context = modelContext
    self.repository = UserRepository(context: modelContext)
    loadUser()
  }
  
  private func loadUser() {
    if let user = try? repository.getUser() {
      self.currentUser = user
    }
  }
  
  /// Updates the current user (called from settings/profile edit)
  func updateUser(_ user: User) {
    self.currentUser = user
  }
  
  /// Seeds guest user and sample data, then loads the user
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
