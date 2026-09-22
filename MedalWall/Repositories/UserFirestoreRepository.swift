//
//  UserFirestoreRepository.swift
//  MedalWall
//
//  Created by Quien on 2026-05-11.
//

import FirebaseFirestore
import Foundation

/// The user store, behind a protocol so callers can be tested against a stub.
///
/// Callers take this as `(any UserRepository)? = nil` and resolve it with
/// `?? UserFirestoreRepository()` inside `init`, because a default argument expression is
/// evaluated in a nonisolated context and cannot construct a `@MainActor` type.
protocol UserRepository {
  /// Fetches the user document, or nil when it does not exist.
  func fetchUser(uid: String) async throws -> User?

  /// Creates a user document. Callers map a failure to `AppError.userSaveFailed`.
  func createUser(_ user: User) async throws

  /// Updates a user document. Callers map a failure to `AppError.userSaveFailed`.
  func updateUser(_ user: User) async throws
}

final class UserFirestoreRepository: UserRepository {
  private var db: Firestore { Firestore.firestore() }
  private let collection = "users"

  /// Fetches the user document. Returns nil if the document does not exist.
  func fetchUser(uid: String) async throws -> User? {
    let snapshot = try await db.collection(collection).document(uid).getDocument()
    guard snapshot.exists else { return nil }
    return try snapshot.data(as: User.self)
  }

  /// Creates a new user document in Firestore.
  func createUser(_ user: User) async throws {
    try db.collection(collection).document(user.uid).setData(from: user)
  }

  /// Replaces the user document with the updated User and stamps updatedAt.
  func updateUser(_ user: User) async throws {
    var updated = user
    updated.updatedAt = Date()
    try db.collection(collection).document(updated.uid).setData(from: updated)
  }
}
