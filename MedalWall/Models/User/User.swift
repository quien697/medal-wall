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
  var unit: String
  
  @Relationship(deleteRule: .cascade, inverse: \Medal.user)
  var medals: [Medal] = []
  
  init(
    id: UUID = UUID(),
    name: UserName,
    avatarData: Data? = nil,
    cropAvatarData: Data? = nil,
    bio: String? = nil,
    gender: Gender? = nil,
    birthday: Date? = nil,
    unit: MeasurementUnit = .km,
    medals: [Medal] = []
  ) {
    self.id = id
    self.firstName = name.firstName
    self.lastName = name.lastName
    self.avatarData = avatarData
    self.cropAvatarData = cropAvatarData
    self.bio = bio
    self.gender = gender?.rawValue
    self.birthday = birthday
    self.unit = unit.rawValue
    self.medals = medals
  }
}

/// Extends Race with computed values
/// Will stay here until v2
extension User {
  var avatar: UIImage? {
    if let avatarData {
      return UIImage(data: avatarData)
    }
    
    return nil
  }
  
  var cropAvatar: UIImage? {
    if let cropAvatarData {
      return UIImage(data: cropAvatarData)
    }
    
    return nil
  }
  
  var genderEnum: Gender? {
    Gender(rawValue: gender ?? "")
  }
  
  var unitEnum: MeasurementUnit {
    MeasurementUnit(rawValue: unit) ?? .km
  }
}
