//
//  RaceFirestoreRepository.swift
//  MedalWall
//
//  Created by Quien on 2026-05-18.
//

import FirebaseFirestore
import Foundation

/// The race store and its edition subcollection, behind a protocol so callers can be
/// tested against a stub.
///
/// Callers take this as `(any RaceRepository)? = nil` and resolve it with
/// `?? RaceFirestoreRepository()` inside `init`, because a default argument expression is
/// evaluated in a nonisolated context and cannot construct a `@MainActor` type.
protocol RaceRepository {
  /// Fetches all races. Callers map a failure to `AppError.raceFetchFailed`.
  func fetchRaces() async throws -> [Race]

  /// Fetches a single race by ID, or nil when it does not exist.
  func fetchRace(id: String) async throws -> Race?

  /// Creates a race. Callers map a failure to `AppError.raceSaveFailed`.
  func createRace(_ race: Race) async throws

  /// Updates a race's own fields. Callers map a failure to `AppError.raceSaveFailed`.
  func updateRace(_ race: Race) async throws

  /// Deletes a race and all of its editions. Callers map a failure to
  /// `AppError.raceDeleteFailed`.
  func deleteRace(id: String) async throws

  /// Fetches all editions for a race. Callers map a failure to `AppError.raceFetchFailed`.
  func fetchEditions(raceId: String) async throws -> [RaceEdition]

  /// Creates an edition and increments its race's count. Callers map a failure to
  /// `AppError.editionSaveFailed`.
  func createEdition(_ edition: RaceEdition) async throws

  /// Updates an edition. Callers map a failure to `AppError.editionSaveFailed`.
  func updateEdition(_ edition: RaceEdition) async throws

  /// Deletes an edition and decrements its race's count. Callers map a failure to
  /// `AppError.editionDeleteFailed`.
  func deleteEdition(raceId: String, editionId: String) async throws
}

final class RaceFirestoreRepository: RaceRepository {
  private var db: Firestore { Firestore.firestore() }
  private let collection = "races"
  private let editionsCollection = "editions"
  private let editionCount = "editionCount"

  // MARK: - Race
  /// Fetches all races created.
  func fetchRaces() async throws -> [Race] {
    let snapshot = try await db.collection(collection).getDocuments()
    return try snapshot.documents.map { try $0.data(as: Race.self) }
  }

  /// Fetches a single race by ID. Returns nil if the document does not exist.
  func fetchRace(id: String) async throws -> Race? {
    let snapshot = try await db.collection(collection).document(id).getDocument()
    guard snapshot.exists else { return nil }
    return try snapshot.data(as: Race.self)
  }

  /// Creates a new race document in Firestore.
  func createRace(_ race: Race) async throws {
    try await db.collection(collection).document(race.id)
      .setData(Firestore.Encoder().encode(race))
  }

  /// Replaces the race document with the updated Race and stamps updatedAt.
  func updateRace(_ race: Race) async throws {
    var updated = race
    updated.updatedAt = Date()
    try await db.collection(collection).document(updated.id)
      .setData(Firestore.Encoder().encode(updated))
  }

  /// Deletes a race and all of its editions.
  func deleteRace(id: String) async throws {
    let editions = try await fetchEditions(raceId: id)
    for edition in editions {
      try await deleteEdition(raceId: id, editionId: edition.id)
    }
    try await db.collection(collection).document(id).delete()
  }

  // MARK: - Race Edition
  private func editionsRef(raceId: String) -> CollectionReference {
    db.collection(collection).document(raceId).collection(editionsCollection)
  }

  /// Fetches all editions for a given race.
  func fetchEditions(raceId: String) async throws -> [RaceEdition] {
    let snapshot = try await editionsRef(raceId: raceId).getDocuments()
    return try snapshot.documents.map { try $0.data(as: RaceEdition.self) }
  }

  /// Creates a new edition document under the race and increments the race's edition count.
  func createEdition(_ edition: RaceEdition) async throws {
    try await editionsRef(raceId: edition.raceId).document(edition.id)
      .setData(Firestore.Encoder().encode(edition))
    try? await db.collection(collection).document(edition.raceId).updateData([
      editionCount: FieldValue.increment(Int64(1))
    ])
  }

  /// Replaces the edition document with the updated RaceEdition and stamps updatedAt.
  func updateEdition(_ edition: RaceEdition) async throws {
    var updated = edition
    updated.updatedAt = Date()
    try await editionsRef(raceId: updated.raceId).document(updated.id)
      .setData(Firestore.Encoder().encode(updated))
  }

  /// Deletes a single edition by ID and decrements the race's edition count.
  func deleteEdition(raceId: String, editionId: String) async throws {
    try await editionsRef(raceId: raceId).document(editionId).delete()
    try? await db.collection(collection).document(raceId).updateData([
      editionCount: FieldValue.increment(Int64(-1))
    ])
  }
}
