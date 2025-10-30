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
  var gender: Gender?
  var birthdate: Date?
  var unit: RaceDistanceUnit
  
  @Relationship(deleteRule: .cascade, inverse: \Medal.user)
  var medals: [Medal] = []
  
  init(
    id: UUID,
    firstName: String,
    lastName: String,
    avatar: String? = nil,
    gender: Gender? = nil,
    birthdate: Date? = nil,
    unit: RaceDistanceUnit = .km,
    medals: [Medal] = []
  ) {
    self.id = id
    self.firstName = firstName
    self.lastName = lastName
    self.avatar = avatar
    self.gender = gender
    self.birthdate = birthdate
    self.unit = unit
    self.medals = medals
  }
}
