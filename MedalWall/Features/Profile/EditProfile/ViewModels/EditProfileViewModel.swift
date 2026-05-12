//
//  EditProfileViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-12-04.
//

import SwiftUI

@Observable
final class EditProfileViewModel {
  // MARK: - Properties
  var userName: UserName
  var avatarData: Data? = nil
  var avatar: UIImage? = nil
  var bio: String
  var gender: Gender?
  var birthday: Date
  var isBirthdaySet: Bool
  
  private let profile: AppUser
  
  // MARK: - Init
  init(profile: AppUser) {
    self.profile = profile
    self.userName = UserName(
      firstName: profile.firstName ?? "",
      lastName: profile.lastName ?? ""
    )
    self.bio = profile.bio ?? ""
    self.gender = profile.gender
    if let birthday = profile.birthday {
      self.birthday = birthday
      self.isBirthdaySet = true
    } else {
      self.birthday = .now
      self.isBirthdaySet = false
    }
  }
  
  // MARK: - Computed
  var isFormValid: Bool {
    !userName.trimmedFirstName.isEmpty
  }
  
  // MARK: - Functions
  
  func updatePhoto(with uiImage: UIImage) {
    self.avatarData = uiImage.pngData()
    self.avatar = uiImage
  }
  
  func clearPhoto() {
    self.avatarData = nil
    self.avatar = nil
  }
  
  /// Returns a copy of the profile with the current draft values applied.
  func makeUpdatedUser() -> AppUser {
    var updated = profile
    updated.firstName = userName.trimmedFirstName
    updated.lastName = userName.trimmedLastName.isEmpty ? nil : userName.trimmedLastName
    updated.bio = bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : bio.trimmingCharacters(in: .whitespacesAndNewlines)
    updated.gender = gender
    updated.birthday = isBirthdaySet ? birthday : nil
    return updated
  }
}
