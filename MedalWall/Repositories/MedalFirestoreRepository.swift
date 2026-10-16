//
//  MedalFirestoreRepository.swift
//  MedalWall
//
//  Created by Quien on 2026-05-26.
//

import FirebaseFirestore
import Foundation

/// The medal store, behind a protocol so callers can be tested against a stub.
///
/// Callers take this as `(any MedalRepository)? = nil` and resolve it with
/// `?? MedalFirestoreRepository()` inside `init`, because a default argument expression is
/// evaluated in a nonisolated context and cannot construct a `@MainActor` type.
protocol MedalRepository {
  /// Fetches all medals for a user. Callers map a failure to `AppError.medalFetchFailed`.
  func fetchMedals(userId: String) async throws -> [Medal]

  /// Fetches a single medal by ID, or nil when it does not exist.
  func fetchMedal(id: String, userId: String) async throws -> Medal?

  /// Creates a medal. Callers map a failure to `AppError.medalSaveFailed`.
  func createMedal(_ medal: Medal) async throws

  /// Updates a medal. Callers map a failure to `AppError.medalSaveFailed`.
  func updateMedal(_ medal: Medal) async throws

  /// Deletes a medal. Callers map a failure to `AppError.medalDeleteFailed`.
  func deleteMedal(id: String, userId: String) async throws
}

final class MedalFirestoreRepository: MedalRepository {
  private var db: Firestore { Firestore.firestore() }

  /// Every medal field an update writes. A cleared optional in this list is deleted from the
  /// stored document; a field missing from it is never touched.
  ///
  /// `MedalFirestoreRepositoryTests` fails if `Medal` gains a field missing from this list.
  static let medalUpdateFields = [
    "id",
    "name",
    "date",
    "bibNumber",
    "photoUrl",
    "place",
    "distance",
    "finishTime",
    "overallPlacement",
    "totalParticipants",
    "division",
    "divisionPlacement",
    "divisionTotal",
    "genderPlacement",
    "genderTotal",
    "note",
    "tags",
    "eventPhotos",
    "userID",
    "createdAt",
    "updatedAt"
  ]

  private func medalsRef(userId: String) -> CollectionReference {
    db.collection("users").document(userId).collection("medals")
  }

  // MARK: - Medal
  /// Fetches all medals for a user.
  func fetchMedals(userId: String) async throws -> [Medal] {
    let snapshot = try await medalsRef(userId: userId).getDocuments()
    return try snapshot.documents.map { try $0.data(as: Medal.self) }
  }

  /// Fetches a single medal by ID. Returns nil if the document does not exist.
  func fetchMedal(id: String, userId: String) async throws -> Medal? {
    let snapshot = try await medalsRef(userId: userId).document(id).getDocument()
    guard snapshot.exists else { return nil }
    return try snapshot.data(as: Medal.self)
  }

  /// Creates a new medal document in Firestore.
  func createMedal(_ medal: Medal) async throws {
    try await medalsRef(userId: medal.userID).document(medal.id)
      .setData(Firestore.Encoder().encode(medal))
  }

  /// Updates the medal's own fields and stamps updatedAt.
  ///
  /// An update rather than a replace, so a field another client stored that `Medal` does not
  /// declare survives the edit. It fails if the medal no longer exists rather than
  /// recreating one deleted elsewhere.
  func updateMedal(_ medal: Medal) async throws {
    var updated = medal
    updated.updatedAt = Date()
    try await medalsRef(userId: updated.userID).document(updated.id)
      .updateData(Self.updateFields(for: updated))
  }

  /// The fields a medal update writes: everything encoded, plus an explicit delete for each
  /// updatable field the medal no longer carries, so clearing a finish time or a note removes
  /// the stored value instead of leaving it behind.
  static func updateFields(for medal: Medal) throws -> [String: Any] {
    var fields = try Firestore.Encoder().encode(medal)
    for field in medalUpdateFields where fields[field] == nil {
      fields[field] = FieldValue.delete()
    }
    return fields
  }

  /// Deletes a medal document.
  func deleteMedal(id: String, userId: String) async throws {
    try await medalsRef(userId: userId).document(id)
      .delete()
  }
}
