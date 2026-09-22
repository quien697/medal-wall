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

  /// Replaces the medal document with the updated Medal and stamps updatedAt.
  func updateMedal(_ medal: Medal) async throws {
    var updated = medal
    updated.updatedAt = Date()
    try await medalsRef(userId: updated.userID).document(updated.id)
      .setData(Firestore.Encoder().encode(updated))
  }

  /// Deletes a medal document.
  func deleteMedal(id: String, userId: String) async throws {
    try await medalsRef(userId: userId).document(id)
      .delete()
  }
}
