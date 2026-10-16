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
  /// Fetches the user document and whether it came from the phone's copy rather than the
  /// server, or nil when the server confirms it does not exist. Throws
  /// `AppError.noInternetConnection` when the device is offline and has no copy of it.
  func fetchUser(uid: String) async throws -> (user: User, isFromCache: Bool)?

  /// Creates a user document. Callers map a failure to `AppError.userSaveFailed`.
  func createUser(_ user: User) async throws

  /// Updates a user document. Callers map a failure to `AppError.userSaveFailed`.
  func updateUser(_ user: User) async throws
}

final class UserFirestoreRepository: UserRepository {
  private var db: Firestore { Firestore.firestore() }
  private let collection = "users"

  /// Every user field an update writes. A cleared optional in this list is deleted from the
  /// stored document; a field missing from it is never touched.
  ///
  /// `UserFirestoreRepositoryTests` fails if `User` gains a field missing from this list.
  static let userUpdateFields = [
    "uid",
    "email",
    "firstName",
    "lastName",
    "photoUrl",
    "bio",
    "gender",
    "birthday",
    "createdAt",
    "updatedAt"
  ]

  /// Fetches the user document, falling back to the phone's copy when offline. Returns nil
  /// if the server confirms the document does not exist; throws
  /// `AppError.noInternetConnection` when neither the server nor the copy has it.
  func fetchUser(uid: String) async throws -> (user: User, isFromCache: Bool)? {
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

  /// Updates the user's own fields and stamps updatedAt.
  ///
  /// An update rather than a replace, so a field another client stored that `User` does not
  /// declare survives the edit. It fails if the profile no longer exists rather than
  /// recreating it.
  func updateUser(_ user: User) async throws {
    var updated = user
    updated.updatedAt = Date()
    try await db.collection(collection).document(updated.uid)
      .updateData(Self.updateFields(for: updated))
  }

  /// The fields a user update writes: everything encoded, plus an explicit delete for each
  /// updatable field the user no longer carries, so clearing a bio or a photo removes the
  /// stored value instead of leaving it behind.
  static func updateFields(for user: User) throws -> [String: Any] {
    var fields = try Firestore.Encoder().encode(user)
    for field in userUpdateFields where fields[field] == nil {
      fields[field] = FieldValue.delete()
    }
    return fields
  }

  /// Reads a fetched snapshot: the profile and whether it came from the phone's copy, or
  /// nil when the server confirms there is none.
  ///
  /// Only the server can say a profile doesn't exist. The phone's copy may simply not hold
  /// it, so a document missing from the copy reads as offline — otherwise a first-sign-in
  /// create could overwrite a profile the server already has.
  static func profile(
    exists: Bool, isFromCache: Bool, decode: () throws -> User
  ) throws -> (user: User, isFromCache: Bool)? {
    guard exists else {
      if isFromCache { throw AppError.noInternetConnection }
      return nil
    }
    return (try decode(), isFromCache)
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
}
