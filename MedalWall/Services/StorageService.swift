//
//  StorageService.swift
//  MedalWall
//
//  Created by Quien on 2026-05-12.
//

@preconcurrency import FirebaseStorage
import UIKit

final class StorageService {
  private var storage: Storage { Storage.storage() }

  // MARK: - Paths
  private enum Path {
    static func userAvatar(uid: String) -> String {
      "users/\(uid)/avatar/profile.jpg"
    }

    static func raceLogo(raceId: String) -> String {
      "races/\(raceId)/logo.jpg"
    }

    static func raceEditionLogo(raceId: String, editionId: String) -> String {
      "races/\(raceId)/editions/\(editionId)/logo.jpg"
    }

    static func medalPhoto(userId: String, medalId: String) -> String {
      "users/\(userId)/medals/\(medalId)/medal.jpg"
    }

    static func medalEventPhoto(userId: String, medalId: String, photoId: String) -> String {
      "users/\(userId)/medals/\(medalId)/eventPhotos/\(photoId).jpg"
    }
  }

  // MARK: - Functions -> User
  /// Uploads a user avatar to Firebase Storage and returns the download URL.
  func uploadUserAvatar(uid: String, image: UIImage) async throws -> String {
    try await upload(image: image, to: Path.userAvatar(uid: uid))
  }

  /// Deletes a user avatar from Firebase Storage.
  func deleteUserAvatar(uid: String) async throws {
    try await delete(at: Path.userAvatar(uid: uid))
  }

  // MARK: - Functions -> Race
  /// Uploads a race logo to Firebase Storage and returns the download URL.
  func uploadRaceLogo(raceId: String, image: UIImage) async throws -> String {
    try await upload(image: image, to: Path.raceLogo(raceId: raceId))
  }

  /// Deletes a race logo from Firebase Storage.
  func deleteRaceLogo(raceId: String) async throws {
    try await delete(at: Path.raceLogo(raceId: raceId))
  }

  /// Uploads a race edition logo to Firebase Storage and returns the download URL.
  func uploadRaceEditionLogo(raceId: String, editionId: String, image: UIImage) async throws
    -> String
  {
    try await upload(image: image, to: Path.raceEditionLogo(raceId: raceId, editionId: editionId))
  }

  /// Deletes a race edition logo from Firebase Storage.
  func deleteRaceEditionLogo(raceId: String, editionId: String) async throws {
    try await delete(at: Path.raceEditionLogo(raceId: raceId, editionId: editionId))
  }

  // MARK: - Functions -> Medal
  /// Uploads a medal cover photo and returns the download URL.
  func uploadMedalPhoto(userId: String, medalId: String, image: UIImage) async throws -> String {
    try await upload(image: image, to: Path.medalPhoto(userId: userId, medalId: medalId))
  }

  /// Deletes a medal cover photo from Firebase Storage.
  func deleteMedalPhoto(userId: String, medalId: String) async throws {
    try await delete(at: Path.medalPhoto(userId: userId, medalId: medalId))
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

  /// Deletes a medal event photo from Firebase Storage.
  func deleteMedalEventPhoto(userId: String, medalId: String, photoId: String) async throws {
    try await delete(at: Path.medalEventPhoto(userId: userId, medalId: medalId, photoId: photoId))
  }

  // MARK: - Functions -> Common
  private func upload(image: UIImage, to path: String) async throws -> String {
    guard let data = image.jpegData(compressionQuality: 0.8) else {
      throw AppError.photoDataInvalid
    }

    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    let ref = storage.reference().child(path)
    _ = try await ref.putDataAsync(data, metadata: metadata)
    let url = try await ref.downloadURL()

    return url.absoluteString
  }

  private func delete(at path: String) async throws {
    try await storage.reference().child(path).delete()
  }
}
