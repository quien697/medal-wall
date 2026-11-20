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
  /// The profile photo as its slot shows it and as save uploads it.
  var photo: DraftPhoto
  var bio: String
  var gender: Gender?
  var birthday: Date?

  // MARK: - State
  /// The photo checks in progress, which Save waits for.
  var photoChecks = PhotoChecks()
  private(set) var isLoading = false

  // MARK: - Dependencies
  private let profile: User
  private let networkMonitor: any NetworkMonitor

  // MARK: - Init
  init(profile: User, networkMonitor: (any NetworkMonitor)? = nil) {
    self.profile = profile
    self.networkMonitor = networkMonitor ?? NWPathNetworkMonitor()
    self.photo = DraftPhoto(storedPhotoUrl: profile.photoUrl)
    self.userName = UserName(
      firstName: profile.firstName ?? "",
      lastName: profile.lastName ?? ""
    )
    self.bio = profile.bio ?? ""
    self.gender = profile.gender
    self.birthday = profile.birthday
  }

  // MARK: - Computed
  /// Whether Save can be tapped: the form is valid and no photo is still being checked.
  var canSave: Bool { isFormValid && !photoChecks.isChecking }

  var isFormValid: Bool {
    !userName.trimmedFirstName.isEmpty && !userName.trimmedLastName.isEmpty
  }

  /// The JPEG to upload on save: only a newly cropped photo's, never the stored photo's.
  var photoToUpload: Data? { photo.isChanged ? photo.croppedPhoto?.jpegData : nil }

  // MARK: - Functions
  /// Downloads the stored profile photo so the form can show it, unless a new one was
  /// picked while it loaded, marking it as failed when it can't be downloaded.
  func loadStoredPhoto() async {
    let storedPhoto = await UIImage.load(from: profile.photoUrl)
    photo.showStored(storedPhoto)
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
    if photo.isChanged && photo.croppedPhoto == nil {
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

    try await userManager.updateUser(makeUpdatedUser(), photoData: photoToUpload)
  }
}
