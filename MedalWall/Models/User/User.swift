//
//  User.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation
import SwiftData

@Model
final class User {
  @Attribute(.unique) var id: UUID
  var firstName: String
  var lastName: String
  var avatar: String?
  var gender: String?
  var birthdate: Date?
  var unit: String
  
  @Relationship(deleteRule: .cascade, inverse: \Medal.user)
  var medals: [Medal] = []
  
  init(
    id: UUID = UUID(),
    name: UserName,
    avatar: String? = nil,
    gender: Gender? = nil,
    birthdate: Date? = nil,
    unit: MeasurementUnit = .km,
    medals: [Medal] = []
  ) {
    self.id = id
    self.firstName = name.firstName
    self.lastName = name.lastName
    self.avatar = avatar
    self.gender = gender?.displayName
    self.birthdate = birthdate
    self.unit = unit.displayName
    self.medals = medals
  }
}
