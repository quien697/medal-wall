//
//  User.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation
import UIKit
import SwiftData

@Model
final class User {
  @Attribute(.unique) var id: UUID
  var firstName: String
  var lastName: String
  var avatarData: Data?
  var cropAvatarData: Data?
  var bio: String?
  var gender: String?
  var birthday: Date?
  var isGuest: Bool
  var createdDate: Date
  var updatedDate: Date
  
  init(
    id: UUID = UUID(),
    name: UserName = UserName(firstName: "", lastName: ""),
    avatarData: Data? = nil,
    cropAvatarData: Data? = nil,
    bio: String? = nil,
    gender: Gender? = nil,
    birthday: Date? = nil,
    isGuest: Bool = false,
    createdDate: Date = Date(),
    updatedDate: Date = Date()
  ) {
    self.id = id
    self.firstName = name.trimmedFirstName
    self.lastName = name.trimmedLastName
    self.avatarData = avatarData
    self.cropAvatarData = cropAvatarData
    self.bio = bio
    self.gender = gender?.rawValue
    self.birthday = birthday
    self.isGuest = isGuest
    self.createdDate = createdDate
    self.updatedDate = updatedDate
  }
}
