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
  private(set) var avatarDeleteCount = 0
  private(set) var uploadedEditionLogoIDs: [String] = []
  private(set) var raceLogoDeleteCount = 0
  private(set) var deletedEditionLogoIDs: [String] = []
  private(set) var medalPhotoDeleteCount = 0
  private(set) var deletedEventPhotoIDs: [String] = []

  // MARK: - Init
  init(uploadOutcome: Result<String, AppError> = .success("https://example.com/uploaded.jpg")) {
    self.uploadOutcome = uploadOutcome
  }

  // MARK: - PhotoStorage
  func uploadUserAvatar(uid: String, image: UIImage) async throws -> String {
    try recordUpload()
  }

  func deleteUserAvatar(uid: String) async throws {
    avatarDeleteCount += 1
  }

  func uploadRaceLogo(raceId: String, image: UIImage) async throws -> String {
    try recordUpload()
  }

  func deleteRaceLogo(raceId: String) async throws {
    raceLogoDeleteCount += 1
  }

  func uploadRaceEditionLogo(raceId: String, editionId: String, image: UIImage) async throws
    -> String
  {
    uploadedEditionLogoIDs.append(editionId)
    return try recordUpload()
  }

  func deleteRaceEditionLogo(raceId: String, editionId: String) async throws {
    deletedEditionLogoIDs.append(editionId)
  }

  func uploadMedalPhoto(userId: String, medalId: String, image: UIImage) async throws -> String {
    try recordUpload()
  }

  func deleteMedalPhoto(userId: String, medalId: String) async throws {
    medalPhotoDeleteCount += 1
  }

  func uploadMedalEventPhoto(
    userId: String, medalId: String, photoId: String, image: UIImage
  ) async throws -> String {
    try recordUpload()
  }

  func deleteMedalEventPhoto(userId: String, medalId: String, photoId: String) async throws {
    deletedEventPhotoIDs.append(photoId)
  }

  // MARK: - Private
  private func recordUpload() throws -> String {
    uploadCallCount += 1
    return try uploadOutcome.get()
  }
}
