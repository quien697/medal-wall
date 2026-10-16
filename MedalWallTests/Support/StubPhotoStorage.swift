//
//  StubPhotoStorage.swift
//  MedalWall
//
//  Created by Quien on 2026-09-30.
//

import UIKit

@testable import MedalWall

/// Scriptable `PhotoStorage` so photo flows can be tested without Firebase Storage.
///
/// An `actor` for the same reason as the repository stubs: `PhotoStorage` is nonisolated,
/// and an actor's isolated methods can witness its `async` requirements.
actor StubPhotoStorage: PhotoStorage {

  // MARK: - Script
  /// What every upload returns: a download URL, or the error it throws.
  private let uploadOutcome: Result<String, AppError>

  // MARK: - Recorded calls
  private(set) var uploadCallCount = 0
  private(set) var uploadedEditionLogoIDs: [String] = []
  private(set) var deletedURLs: [String] = []
  private(set) var deletedOwners: [PhotoOwner] = []

  // MARK: - Init
  init(uploadOutcome: Result<String, AppError> = .success("https://example.com/uploaded.jpg")) {
    self.uploadOutcome = uploadOutcome
  }

  // MARK: - PhotoStorage
  func uploadUserAvatar(uid: String, image: UIImage) async throws -> String {
    try recordUpload()
  }

  func uploadRaceLogo(raceId: String, image: UIImage) async throws -> String {
    try recordUpload()
  }

  func uploadRaceEditionLogo(raceId: String, editionId: String, image: UIImage) async throws
    -> String
  {
    uploadedEditionLogoIDs.append(editionId)
    return try recordUpload()
  }

  func uploadMedalPhoto(userId: String, medalId: String, image: UIImage) async throws -> String {
    try recordUpload()
  }

  func uploadMedalEventPhoto(
    userId: String, medalId: String, photoId: String, image: UIImage
  ) async throws -> String {
    try recordUpload()
  }

  func deletePhoto(url: String, ownedBy owner: PhotoOwner) async throws {
    deletedURLs.append(url)
    deletedOwners.append(owner)
  }

  // MARK: - Private
  private func recordUpload() throws -> String {
    uploadCallCount += 1
    return try uploadOutcome.get()
  }
}
