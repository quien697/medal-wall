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
  private var fetchOutcome: Result<Void, AppError>
  /// Whether a fetch reports the user as read from the phone's copy rather than the server.
  private var fetchesFromCache: Bool
  private let writeOutcome: Result<Void, AppError>
  /// How long a create takes to be acknowledged by the server.
  private let createLatency: Duration

  // MARK: - Recorded calls
  private(set) var fetchCallCount = 0
  private(set) var createdUsers: [User] = []
  private(set) var updatedUsers: [User] = []

  // MARK: - Init
  init(
    user: User? = nil,
    fetchOutcome: Result<Void, AppError> = .success(()),
    writeOutcome: Result<Void, AppError> = .success(()),
    createLatency: Duration = .zero,
    fetchesFromCache: Bool = false
  ) {
    self.user = user
    self.fetchOutcome = fetchOutcome
    self.fetchesFromCache = fetchesFromCache
    self.writeOutcome = writeOutcome
    self.createLatency = createLatency
  }

  // MARK: - Script control
  /// Changes what later fetches do, as when the connection comes back.
  func setFetchOutcome(_ outcome: Result<Void, AppError>) {
    fetchOutcome = outcome
  }

  /// Changes whether later fetches come from the phone's copy, as when the server is
  /// reachable again.
  func setFetchesFromCache(_ isFromCache: Bool) {
    fetchesFromCache = isFromCache
  }

  // MARK: - UserRepository
  func fetchUser(uid: String) async throws -> (user: User, isFromCache: Bool)? {
    fetchCallCount += 1
    try fetchOutcome.get()
    guard let user, user.uid == uid else { return nil }
    return (user, fetchesFromCache)
  }

  func createUser(_ user: User) async throws {
    try await Task.sleep(for: createLatency)
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
