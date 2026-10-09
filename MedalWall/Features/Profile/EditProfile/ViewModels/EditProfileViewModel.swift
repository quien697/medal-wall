//
//  EditProfileViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-12-04.
//

import SwiftUI

@Observable
final class EditProfileViewModel {
  // MARK: - Data
  var userName: UserName
  var photo: UIImage?
  var bio: String
  var gender: Gender?
  var birthday: Date?

  // MARK: - State
  private(set) var isPhotoChanged = false
  private(set) var isLoading = false

  // MARK: - Dependencies
  private let profile: User
  private let networkMonitor: any NetworkMonitor

  // MARK: - Init
  init(profile: User, networkMonitor: (any NetworkMonitor)? = nil) {
    self.profile = profile
    self.networkMonitor = networkMonitor ?? NWPathNetworkMonitor()
    self.photo = nil
    self.userName = UserName(
      firstName: profile.firstName ?? "",
      lastName: profile.lastName ?? ""
    )
    self.bio = profile.bio ?? ""
    self.gender = profile.gender
    self.birthday = profile.birthday
  }

  // MARK: - Computed
  var isFormValid: Bool {
    !userName.trimmedFirstName.isEmpty && !userName.trimmedLastName.isEmpty
  }

  /// The photo to upload on save — only a newly picked one, never the existing photo.
  var photoToUpload: UIImage? { isPhotoChanged ? photo : nil }

  // MARK: - Functions
  func loadExistingPhoto() async {
    let existingPhoto = await UIImage.load(from: profile.photoUrl)
    guard !isPhotoChanged else { return }

    photo = existingPhoto
  }

  func updatePhoto(with uiImage: UIImage) {
    photo = uiImage
    isPhotoChanged = true
  }

  func clearPhoto() {
    photo = nil
    isPhotoChanged = true
  }

  /// Returns a copy of the profile with the current draft values applied.
  func makeUpdatedUser() -> User {
    var updated = profile
    updated.firstName = userName.trimmedFirstName
    updated.lastName = userName.trimmedLastName
    let updatedBio = bio.trimmingCharacters(in: .whitespacesAndNewlines)
    updated.bio = updatedBio.isEmpty ? nil : updatedBio
    updated.gender = gender
    updated.birthday = birthday
    if isPhotoChanged && photo == nil {
      updated.photoUrl = nil
    }
    return updated
  }

  /// Saves the edited profile, uploading the photo only when it changed. Offline, it throws
  /// `AppError.noInternetConnection` before uploading or writing anything.
  func save(userManager: UserManager) async throws {
    isLoading = true
    defer { isLoading = false }

    guard await networkMonitor.isConnected() else { throw AppError.noInternetConnection }

    try await userManager.updateUser(makeUpdatedUser(), photo: photoToUpload)
  }
}
