//
//  StubMedalRepository.swift
//  MedalWall
//
//  Created by Quien on 2026-09-22.
//

import Foundation

@testable import MedalWall

/// Scriptable `MedalRepository` so medal flows can be tested without Firestore.
///
/// An `actor` rather than a `@MainActor` class: `MedalRepository` is nonisolated, and an
/// actor's isolated methods can witness its `async` requirements while the stub's recorded
/// state stays safe to read from a test.
actor StubMedalRepository: MedalRepository {

  // MARK: - Script
  /// The medals a fetch returns, and the store writes land in.
  private(set) var medals: [Medal]
  private let fetchOutcome: Result<Void, AppError>
  private let writeOutcome: Result<Void, AppError>
  private let deleteOutcome: Result<Void, AppError>

  // MARK: - Recorded calls
  private(set) var fetchCallCount = 0
  private(set) var createdMedals: [Medal] = []
  private(set) var updatedMedals: [Medal] = []
  private(set) var deletedMedalIDs: [String] = []

  // MARK: - Init
  init(
    medals: [Medal] = [],
    fetchOutcome: Result<Void, AppError> = .success(()),
    writeOutcome: Result<Void, AppError> = .success(()),
    deleteOutcome: Result<Void, AppError> = .success(())
  ) {
    self.medals = medals
    self.fetchOutcome = fetchOutcome
    self.writeOutcome = writeOutcome
    self.deleteOutcome = deleteOutcome
  }

  // MARK: - MedalRepository
  func fetchMedals(userId: String) async throws -> [Medal] {
    fetchCallCount += 1
    try fetchOutcome.get()
    return medals.filter { $0.userID == userId }
  }

  func fetchMedal(id: String, userId: String) async throws -> Medal? {
    fetchCallCount += 1
    try fetchOutcome.get()
    return medals.first { $0.id == id && $0.userID == userId }
  }

  func createMedal(_ medal: Medal) async throws {
    try writeOutcome.get()
    createdMedals.append(medal)
    medals.append(medal)
  }

  func updateMedal(_ medal: Medal) async throws {
    try writeOutcome.get()
    updatedMedals.append(medal)
    if let index = medals.firstIndex(where: { $0.id == medal.id }) {
      medals[index] = medal
    }
  }

  func deleteMedal(id: String, userId: String) async throws {
    try deleteOutcome.get()
    deletedMedalIDs.append(id)
    medals.removeAll { $0.id == id && $0.userID == userId }
  }
}
