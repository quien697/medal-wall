//
//  EditProfileViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-12-04.
//

import SwiftUI
import SwiftData

@Observable
class EditProfileViewModel {
  var userName: UserName = UserName(firstName: "", lastName: "")
  var avatarData: Data? = nil
  var avatar: UIImage? = nil
  var bio: String = ""
  var gender: Gender? = nil
  var birthday: Date = .now
  var isBirthdaySet: Bool = false
  
  let mode: ItemEditMode
  private var repository: UserRepository?
  private let profile: User?
  
  init(mode: ItemEditMode, profile: User?) {
    self.mode = mode
    self.profile = profile
    
    if let profile {
      self.userName = UserName(
        firstName: profile.firstName,
        lastName: profile.lastName
      )
      self.avatarData = profile.avatarData
      self.avatar = profile.avatar
      self.bio = profile.bio ?? ""
      self.gender = profile.genderEnum
      if let birthday = profile.birthday {
        self.birthday = birthday
        self.isBirthdaySet = true
      }
    }
  }
  
  var isFormValid: Bool {
    !userName.trimmedFirstName.isEmpty &&
    !userName.trimmedLastName.isEmpty
  }
  
  // MARK: - Functions
  
  func configure(context: ModelContext) {
    self.repository = UserRepository(context: context)
  }
  
  func updatePhoto(with uiImage: UIImage) {
    self.avatarData = uiImage.pngData()
    self.avatar = uiImage
  }
  
  func clearPhoto() {
    self.avatarData = nil
    self.avatar = nil
  }
  
  func save() throws {
    guard let repository else { throw AppError.contextNotAttached }
    
    if let profile {
      profile.firstName = userName.trimmedFirstName
      profile.lastName = userName.trimmedLastName
      profile.avatarData = avatarData
      profile.bio = bio
      profile.gender = gender?.rawValue
      profile.birthday = isBirthdaySet ? birthday : nil
      profile.updatedDate = Date()
    } else {
      let newProfile = User(
        name: userName,
        avatarData: avatarData,
        bio: bio,
        gender: gender,
        birthday: isBirthdaySet ? birthday : nil
      )
      try repository.insertUser(newProfile)
    }
    
    try repository.save()
  }
}
