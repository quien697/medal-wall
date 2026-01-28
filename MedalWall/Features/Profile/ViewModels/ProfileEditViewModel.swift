//
//  ProfileEditViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-12-04.
//

import SwiftUI
import SwiftData

@Observable
class ProfileEditViewModel {
  var userName: UserName = UserName(firstName: "", lastName: "")
  var avatarData: Data? = nil
  var avatar: UIImage? = nil
  var cropAvatarData: Data? = nil
  var cropAvatar: UIImage? = nil
  var bio: String = ""
  var gender: Gender? = nil
  var birthday: Date = .now
  var isBirthdaySet: Bool = false
  var unit: MeasurementUnit = .km
  var isNewProfile: Bool = true
  
  private let repository: UserRepository
  private(set) var profile: User?
  
  init(profile: User?, repository: UserRepository = UserRepository()) {
    self.repository = repository
    self.profile = profile
    
    if let profile {
      self.profile = profile
      self.userName = UserName(firstName: profile.firstName, lastName: profile.lastName)
      self.avatarData = profile.avatarData
      self.avatar = profile.avatar
      self.cropAvatarData = profile.cropAvatarData
      self.cropAvatar = profile.cropAvatar
      self.bio = profile.bio ?? ""
      self.gender = profile.genderEnum
      if let birthday = profile.birthday {
        self.birthday = birthday
        self.isBirthdaySet = true
      }
      self.unit = profile.unitEnum
      self.isNewProfile = false
    }
  }
  
  func attachContext(_ context: ModelContext) throws {
    repository.attachContext(context)
  }
  
  var isFormValid: Bool {
    !userName.firstName.trimmingCharacters(in: .whitespaces).isEmpty &&
    !userName.lastName.trimmingCharacters(in: .whitespaces).isEmpty
  }
  
  func updatePhoto(with data: Data?) {
    self.avatarData = data
    
    if let data {
      self.avatar = UIImage(data: data)
    } else {
      self.avatar = nil
    }
  }
  
  func updateCropPhoto(with uiImage: UIImage) {
    self.cropAvatarData = uiImage.pngData()
    self.cropAvatar = uiImage
  }
  
  func clearPhoto() {
    self.avatarData = nil
    self.avatar = nil
    self.cropAvatarData = nil
    self.cropAvatar = nil
  }

  func save() throws {
    if let profile {
      profile.firstName = userName.firstName
      profile.lastName = userName.lastName
      profile.avatarData = avatarData
      profile.cropAvatarData = cropAvatarData
      profile.bio = bio
      profile.gender = gender?.rawValue
      profile.birthday = isBirthdaySet ? birthday : nil
      profile.unit = unit.rawValue
    } else {
      let newProfile = User(
        name: userName,
        avatarData: avatarData,
        cropAvatarData: cropAvatarData,
        bio: bio,
        gender: gender,
        birthday: isBirthdaySet ? birthday : nil,
        unit: unit
      )
      
      try repository.insertUser(newProfile)
    }
    
    try repository.save()
  }
}
