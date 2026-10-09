//
//  StorageService.swift
//  MedalWall
//
//  Created by Quien on 2026-05-12.
//

@preconcurrency import FirebaseStorage
import UIKit

/// Photo uploads and deletions, behind a protocol so callers can be tested against a stub.
///
/// Callers take this as `(any PhotoStorage)? = nil` and resolve it with `?? StorageService()`
/// inside `init`, for the same reason the repositories do.
protocol PhotoStorage {
  /// Uploads a user avatar and returns its download URL.
  func uploadUserAvatar(uid: String, image: UIImage) async throws -> String

  /// Uploads a race logo and returns its download URL.
  func uploadRaceLogo(raceId: String, image: UIImage) async throws -> String

  /// Uploads a race edition logo and returns its download URL.
  func uploadRaceEditionLogo(raceId: String, editionId: String, image: UIImage) async throws
    -> String

  /// Uploads a medal cover photo and returns its download URL.
  func uploadMedalPhoto(userId: String, medalId: String, image: UIImage) async throws -> String

  /// Uploads a medal event photo and returns its download URL.
  func uploadMedalEventPhoto(
    userId: String, medalId: String, photoId: String, image: UIImage
  ) async throws -> String

  /// Deletes the photo stored at a download URL.
  func deletePhoto(url: String) async throws
}

extension PhotoStorage {
  /// Deletes a deleted race's logo and each of its editions' logos. Call only once the race is
  /// gone, so a failed delete never leaves it pointing at deleted files; a logo that fails to
  /// delete is left behind rather than failing a delete that already happened.
  func deleteLogos(of race: Race, editions: [RaceEdition]) async {
    if let photoUrl = race.photoUrl {
      try? await deletePhoto(url: photoUrl)
    }
    for edition in editions {
      if let photoUrl = edition.photoUrl {
        try? await deletePhoto(url: photoUrl)
      }
    }
  }
}

final class StorageService: PhotoStorage {
  /// How long an upload keeps retrying without a connection before it fails, instead of
  /// Storage's default 10 minutes, so a save cannot sit on its spinner that long.
  private static let maxUploadRetryTime: TimeInterval = 30

  private var storage: Storage {
    let storage = Storage.storage()
    storage.maxUploadRetryTime = Self.maxUploadRetryTime
    return storage
  }

  // MARK: - Paths
  /// Each replaceable photo gets a new file name on every upload, so an upload never
  /// overwrites the file a saved record still points at.
  private enum Path {
    static func userAvatar(uid: String) -> String {
      "users/\(uid)/avatar/\(UUID().uuidString).jpg"
    }

    static func raceLogo(raceId: String) -> String {
      "races/\(raceId)/raceLogo/\(UUID().uuidString).jpg"
    }

    static func raceEditionLogo(raceId: String, editionId: String) -> String {
      "races/\(raceId)/editions/\(editionId)/editionLogo/\(UUID().uuidString).jpg"
    }

    static func medalPhoto(userId: String, medalId: String) -> String {
      "users/\(userId)/medals/\(medalId)/cover/\(UUID().uuidString).jpg"
    }

    /// Named after its `EventPhoto.id` (a UUID made when the photo is picked), so a file in
    /// Storage can be matched to its record. An event photo is never replaced, only added or
    /// removed, so its id is already unique per upload. Gallery order comes from `sortOrder`,
    /// not the file name.
    static func medalEventPhoto(userId: String, medalId: String, photoId: String) -> String {
      "users/\(userId)/medals/\(medalId)/eventPhotos/\(photoId).jpg"
    }
  }

  // MARK: - Functions -> User
  /// Uploads a user avatar to Firebase Storage and returns the download URL.
  func uploadUserAvatar(uid: String, image: UIImage) async throws -> String {
    try await upload(image: image, to: Path.userAvatar(uid: uid))
  }

  // MARK: - Functions -> Race
  /// Uploads a race logo to Firebase Storage and returns the download URL.
  func uploadRaceLogo(raceId: String, image: UIImage) async throws -> String {
    try await upload(image: image, to: Path.raceLogo(raceId: raceId))
  }

  /// Uploads a race edition logo to Firebase Storage and returns the download URL.
  func uploadRaceEditionLogo(raceId: String, editionId: String, image: UIImage) async throws
    -> String
  {
    try await upload(image: image, to: Path.raceEditionLogo(raceId: raceId, editionId: editionId))
  }

  // MARK: - Functions -> Medal
  /// Uploads a medal cover photo and returns the download URL.
  func uploadMedalPhoto(userId: String, medalId: String, image: UIImage) async throws -> String {
    try await upload(image: image, to: Path.medalPhoto(userId: userId, medalId: medalId))
  }

  /// Uploads a medal event photo and returns the download URL.
  func uploadMedalEventPhoto(
    userId: String, medalId: String, photoId: String, image: UIImage
  ) async throws -> String {
    try await upload(
      image: image,
      to: Path.medalEventPhoto(userId: userId, medalId: medalId, photoId: photoId)
    )
  }

  // MARK: - Functions -> Common
  /// Deletes the photo at a download URL from Firebase Storage. Uses the throwing
  /// `reference(for:)`: `reference(forURL:)` stops the app on a malformed URL or one from
  /// another bucket, and photo URLs come from documents other clients may write.
  func deletePhoto(url: String) async throws {
    guard let photoURL = URL(string: url) else { throw AppError.photoDataInvalid }
    try await storage.reference(for: photoURL).delete()
  }

  private func upload(image: UIImage, to path: String) async throws -> String {
    guard let data = image.uploadData() else {
      throw AppError.photoDataInvalid
    }

    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    let ref = storage.reference().child(path)
    _ = try await ref.putDataAsync(data, metadata: metadata)
    let url = try await ref.downloadURL()

    return url.absoluteString
  }
}
