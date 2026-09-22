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
  private static let collection = "races"
  private static let editionsCollection = "editions"
  private static let editionCountField = "editionCount"

  /// Firestore commits at most 500 operations in one batch.
  static let batchLimit = 500

  /// Every race field an update writes. `editionCount` is absent on purpose: the edition
  /// operations own it, and a client editing a name holds only the count it read earlier.
  ///
  /// `RaceFirestoreRepositoryTests` fails if `Race` gains a field missing from this list,
  /// so a new field cannot quietly stop being saved.
  static let raceUpdateFields = [
    "id",
    "name",
    "photoUrl",
    "place",
    "websiteUrl",
    "createdBy",
    "createdAt",
    "updatedAt"
  ]

  // MARK: - Race
  /// Fetches all races created.
  func fetchRaces() async throws -> [Race] {
    let snapshot = try await db.collection(Self.collection).getDocuments()
    return try snapshot.documents.map { try $0.data(as: Race.self) }
  }

  /// Fetches a single race by ID. Returns nil if the document does not exist.
  func fetchRace(id: String) async throws -> Race? {
    let snapshot = try await db.collection(Self.collection).document(id).getDocument()
    guard snapshot.exists else { return nil }
    return try snapshot.data(as: Race.self)
  }

  /// Creates a new race document in Firestore, establishing its edition count at zero.
  func createRace(_ race: Race) async throws {
    try await db.collection(Self.collection).document(race.id)
      .setData(Firestore.Encoder().encode(race))
  }

  /// Updates the race's own fields and stamps updatedAt, leaving `editionCount` untouched.
  ///
  /// An update rather than a replace, so a count another client incremented between this
  /// race being read and saved survives the edit. It fails if the race no longer exists,
  /// which is correct: an edit should not resurrect a race someone else deleted.
  func updateRace(_ race: Race) async throws {
    var updated = race
    updated.updatedAt = Date()
    try await db.collection(Self.collection).document(updated.id)
      .updateData(Self.updateFields(for: updated))
  }

  /// The fields a race update writes: everything encoded except `editionCount`, plus an
  /// explicit delete for each updatable field the race no longer carries, so clearing a
  /// photo or a website URL removes the stored value instead of leaving it behind.
  static func updateFields(for race: Race) throws -> [String: Any] {
    var fields = try Firestore.Encoder().encode(race)
    fields.removeValue(forKey: editionCountField)

    for field in raceUpdateFields where fields[field] == nil {
      fields[field] = FieldValue.delete()
    }
    return fields
  }

  /// Deletes a race and all of its editions in batched commits, since Firestore does not
  /// cascade-delete subcollections.
  ///
  /// No count updates: decrementing a document this same batch deletes is work for nothing.
  func deleteRace(id: String) async throws {
    let editionIds = try await fetchEditions(raceId: id).map { $0.id }
    let chunks = Self.deletionChunks(editionIds: editionIds)

    for (index, chunk) in chunks.enumerated() {
      let batch = db.batch()
      for editionId in chunk {
        batch.deleteDocument(editionsRef(raceId: id).document(editionId))
      }
      if index == chunks.count - 1 {
        batch.deleteDocument(db.collection(Self.collection).document(id))
      }
      try await batch.commit()
    }
  }

  /// Splits edition ids into batches that leave room for the race delete, which always goes
  /// in the last one: an interrupted delete then leaves a race holding fewer editions rather
  /// than editions orphaned under a race that is already gone.
  static func deletionChunks(editionIds: [String], limit: Int = batchLimit) -> [[String]] {
    guard !editionIds.isEmpty else { return [[]] }

    return stride(from: 0, to: editionIds.count, by: limit - 1).map { start in
      Array(editionIds[start..<min(start + limit - 1, editionIds.count)])
    }
  }

  // MARK: - Race Edition
  private func editionsRef(raceId: String) -> CollectionReference {
    db.collection(Self.collection).document(raceId)
      .collection(Self.editionsCollection)
  }

  /// Fetches all editions for a given race.
  func fetchEditions(raceId: String) async throws -> [RaceEdition] {
    let snapshot = try await editionsRef(raceId: raceId).getDocuments()
    return try snapshot.documents.map { try $0.data(as: RaceEdition.self) }
  }

  /// Creates a new edition document under the race and increments the race's edition count,
  /// both in one batch so the edition and the count cannot disagree.
  func createEdition(_ edition: RaceEdition) async throws {
    let batch = db.batch()
    try batch.setData(
      from: edition, forDocument: editionsRef(raceId: edition.raceId).document(edition.id))
    batch.updateData(
      [Self.editionCountField: FieldValue.increment(Int64(1))],
      forDocument: db.collection(Self.collection).document(edition.raceId)
    )
    try await batch.commit()
  }

  /// Replaces the edition document with the updated RaceEdition and stamps updatedAt.
  func updateEdition(_ edition: RaceEdition) async throws {
    var updated = edition
    updated.updatedAt = Date()
    try await editionsRef(raceId: updated.raceId).document(updated.id)
      .setData(Firestore.Encoder().encode(updated))
  }

  /// Deletes a single edition and decrements the race's edition count, both in one batch so
  /// the edition and the count cannot disagree.
  func deleteEdition(raceId: String, editionId: String) async throws {
    let batch = db.batch()
    batch.deleteDocument(editionsRef(raceId: raceId).document(editionId))
    batch.updateData(
      [Self.editionCountField: FieldValue.increment(Int64(-1))],
      forDocument: db.collection(Self.collection).document(raceId)
    )
    try await batch.commit()
  }
}
