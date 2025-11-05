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
  var name: UserName
  var avatar: String?
  var gender: Gender?
  var birthdate: Date?
  @Relationship(deleteRule: .cascade, inverse: \Medal.user)
  var medals: [Medal] = []
  var unit: MeasurementUnit
  
  init(
    id: UUID = UUID(),
    name: UserName,
    avatar: String? = nil,
    gender: Gender? = nil,
    birthdate: Date? = nil,
    medals: [Medal] = [],
    unit: MeasurementUnit = .km,
  ) {
    self.id = id
    self.name = name
    self.avatar = avatar
    self.gender = gender
    self.birthdate = birthdate
    self.unit = unit
    self.medals = medals
  }
}
