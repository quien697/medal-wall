//
//  Race.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation
import SwiftData

@Model
final class Race {
  @Attribute(.unique) var id: UUID
  var name: String
  var photoData: Data?
  var country: String
  var province: String?
  var city: String
  var district: String?
  var url: String?
  var createdBy: String
  var createdDate: Date
  var updatedDate: Date
  
  @Relationship(deleteRule: .cascade, inverse: \RaceEdition.race)
  var editions: [RaceEdition] = []
  
  init(
    id: UUID = UUID(),
    name: String,
    photoData: Data? = nil,
    location: RaceLocation,
    url: String? = nil,
    createdBy: String,
    createdDate: Date = .now,
    updatedDate: Date = .now,
    editions: [RaceEdition] = []
  ) {
    self.id = id
    self.name = name
    self.photoData = photoData
    self.country = location.country
    self.province = location.province
    self.city = location.city
    self.district = location.district
    self.url = url
    self.createdBy = createdBy
    self.createdDate = createdDate
    self.updatedDate = updatedDate
    self.editions = editions
  }
}
