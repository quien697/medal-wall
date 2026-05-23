//
//  StorageService.swift
//  MedalWall
//
//  Created by Quien on 2026-05-12.
//

import UIKit
@preconcurrency import FirebaseStorage

final class StorageService {
  private let storage = Storage.storage()
  
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
  func uploadRaceEditionLogo(raceId: String, editionId: String, image: UIImage) async throws -> String {
    try await upload(image: image, to: Path.raceEditionLogo(raceId: raceId, editionId: editionId))
  }

  /// Deletes a race edition logo from Firebase Storage.
  func deleteRaceEditionLogo(raceId: String, editionId: String) async throws {
    try await delete(at: Path.raceEditionLogo(raceId: raceId, editionId: editionId))
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
