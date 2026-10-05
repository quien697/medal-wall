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
  /// Fetches the user document, or nil when the server confirms it does not exist. Throws
  /// `AppError.noInternetConnection` when the device is offline and has no copy of it.
  func fetchUser(uid: String) async throws -> User?

  /// Creates a user document. Callers map a failure to `AppError.userSaveFailed`.
  func createUser(_ user: User) async throws

  /// Updates a user document. Callers map a failure to `AppError.userSaveFailed`.
  func updateUser(_ user: User) async throws
}

final class UserFirestoreRepository: UserRepository {
  private var db: Firestore { Firestore.firestore() }
  private let collection = "users"

  /// Fetches the user document, falling back to the phone's copy when offline. Returns nil
  /// if the server confirms the document does not exist; throws
  /// `AppError.noInternetConnection` when neither the server nor the copy has it.
  func fetchUser(uid: String) async throws -> User? {
    let snapshot: DocumentSnapshot
    do {
      snapshot = try await db.collection(collection).document(uid).getDocument()
    } catch {
      throw Self.fetchError(for: error)
    }
    return try Self.profile(
      exists: snapshot.exists,
      isFromCache: snapshot.metadata.isFromCache,
      decode: { try snapshot.data(as: User.self) }
    )
  }

  /// Creates a new user document in Firestore.
  func createUser(_ user: User) async throws {
    try await db.collection(collection).document(user.uid)
      .setData(Firestore.Encoder().encode(user))
  }

  /// Reads a fetched snapshot: the profile, or nil when the server confirms there is none.
  ///
  /// Only the server can say a profile doesn't exist. The phone's copy may simply not hold
  /// it, so a document missing from the copy reads as offline — otherwise a first-sign-in
  /// create could overwrite a profile the server already has.
  static func profile(exists: Bool, isFromCache: Bool, decode: () throws -> User) throws -> User? {
    guard exists else {
      if isFromCache { throw AppError.noInternetConnection }
      return nil
    }
    return try decode()
  }

  /// Maps Firestore's "server unreachable" error to `AppError.noInternetConnection`, so a
  /// caller can tell waiting for a connection from a real failure. Other errors pass through.
  static func fetchError(for error: Error) -> Error {
    let nsError = error as NSError
    guard nsError.domain == FirestoreErrorDomain,
      nsError.code == FirestoreErrorCode.unavailable.rawValue
    else { return error }

    return AppError.noInternetConnection
  }

  /// Replaces the user document with the updated User and stamps updatedAt.
  func updateUser(_ user: User) async throws {
    var updated = user
    updated.updatedAt = Date()
    try await db.collection(collection).document(updated.uid)
      .setData(Firestore.Encoder().encode(updated))
  }
}
