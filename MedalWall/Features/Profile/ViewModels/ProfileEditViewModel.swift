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
  var bio: String = ""
  var gender: Gender? = nil
  var birthday: Date = .now
  var isBirthdaySet: Bool = false
  var unit: MeasurementUnit = .km
  
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
      self.bio = profile.bio ?? ""
      self.gender = profile.genderEnum
      if let birthday = profile.birthday {
        self.birthday = birthday
        self.isBirthdaySet = true
      }
      self.unit = profile.unitEnum
    }
  }
  
  func attachContext(_ context: ModelContext) throws {
    repository.attachContext(context)
  }
  
  func updateAvatar(with data: Data?) {
    self.avatarData = data
    
    if let data {
      self.avatar = UIImage(data: data)
    } else {
      self.avatar = nil
    }
  }
  
  func clearAvatar() {
    self.avatarData = nil
    self.avatar = nil
  }
  
  func save() throws {
    print("save")
    if let profile {
      print("update")
      profile.firstName = userName.firstName
      profile.lastName = userName.lastName
      profile.avatarData = avatarData
      profile.bio = bio
      profile.gender = gender?.rawValue
      profile.birthday = isBirthdaySet ? birthday : nil
      profile.unit = unit.rawValue
    } else {
//      let newProfile =
//      
//      try repository.insertRace(newRace)
    }
    print("before save()")
    try repository.save()
    print("after save()")
  }
}
