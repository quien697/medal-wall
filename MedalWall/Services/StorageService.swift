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
  
  // MARK: - Functions
  
  /// Uploads a user avatar to Firebase Storage and returns the download URL.
  func uploadUserAvatar(uid: String, image: UIImage) async throws -> String {
    guard let data = image.jpegData(compressionQuality: 0.8) else {
      throw AppError.photoDataInvalid
    }
    
    let metadata = StorageMetadata()
    metadata.contentType = "image/jpeg"
    let ref = storage.reference().child("users/\(uid)/avatar/profile.jpg")
    _ = try await ref.putDataAsync(data, metadata: metadata)
    let url = try await ref.downloadURL()
    
    return url.absoluteString
  }
}
