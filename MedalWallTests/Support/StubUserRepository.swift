//
//  StubUserRepository.swift
//  MedalWall
//
//  Created by Quien on 2026-09-22.
//

import Foundation

@testable import MedalWall

/// Scriptable `UserRepository` so profile writes can be tested without Firestore.
///
/// An `actor` for the same reason as `StubMedalRepository`.
actor StubUserRepository: UserRepository {

  // MARK: - Script
  /// The user a fetch returns; nil stands for "no document yet".
  private(set) var user: User?
  private let fetchOutcome: Result<Void, AppError>
  private let writeOutcome: Result<Void, AppError>

  // MARK: - Recorded calls
  private(set) var fetchCallCount = 0
  private(set) var createdUsers: [User] = []
  private(set) var updatedUsers: [User] = []

  // MARK: - Init
  init(
    user: User? = nil,
    fetchOutcome: Result<Void, AppError> = .success(()),
    writeOutcome: Result<Void, AppError> = .success(())
  ) {
    self.user = user
    self.fetchOutcome = fetchOutcome
    self.writeOutcome = writeOutcome
  }

  // MARK: - UserRepository
  func fetchUser(uid: String) async throws -> User? {
    fetchCallCount += 1
    try fetchOutcome.get()
    return user?.uid == uid ? user : nil
  }

  func createUser(_ user: User) async throws {
    try writeOutcome.get()
    createdUsers.append(user)
    self.user = user
  }

  func updateUser(_ user: User) async throws {
    try writeOutcome.get()
    updatedUsers.append(user)
    self.user = user
  }
}
