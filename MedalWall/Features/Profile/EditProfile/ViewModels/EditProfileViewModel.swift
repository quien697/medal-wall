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
  var photo: UIImage?
  private(set) var isPhotoChanged = false
  var bio: String
  var gender: Gender?
  var birthday: Date
  var isBirthdaySet: Bool
  
  private let profile: User
  
  // MARK: - Init
  init(profile: User) {
    self.profile = profile
    self.photo = nil
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
  
  func loadExistingPhoto() async {
    guard let urlString = profile.photoUrl,
          let url = URL(string: urlString),
          let (data, _) = try? await URLSession.shared.data(from: url),
          let image = UIImage(data: data) else { return }
    
    photo = image
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
    updated.lastName = userName.trimmedLastName.isEmpty ? nil : userName.trimmedLastName
    updated.bio = bio.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : bio.trimmingCharacters(in: .whitespacesAndNewlines)
    updated.gender = gender
    updated.birthday = isBirthdaySet ? birthday : nil
    return updated
  }
}
