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
  var photo: String?
  var date: Date
  var country: String
  var province: String?
  var city: String
  var district: String?
  var sport: String
  var type: String
  var url: String?
  var updateTime: Date
  
  @Relationship(deleteRule: .cascade, inverse: \RaceCategory.race)
  var categories: [RaceCategory] = []
  
  init(
    id: UUID = UUID(),
    name: String,
    photo: String? = nil,
    date: Date,
    location: RaceLocation,
    sport: Sport = .running,
    type: RaceType,
    url: String? = nil,
    updateTime: Date,
    categories: [RaceCategory]
  ) {
    self.id = id
    self.name = name
    self.photo = photo
    self.date = date
    self.country = location.country
    self.province = location.province
    self.city = location.city
    self.district = location.district
    self.sport = sport.displayName
    self.type = type.displayName
    self.url = url
    self.updateTime = updateTime
    self.categories = categories
  }
}
