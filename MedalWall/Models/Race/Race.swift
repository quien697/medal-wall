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
    type: RaceType = .road,
    url: String? = nil,
    updateTime: Date = .now,
    categories: [RaceCategory] = []
  ) {
    self.id = id
    self.name = name
    self.photo = photo
    self.date = date
    self.country = location.country
    self.province = location.province
    self.city = location.city
    self.district = location.district
    self.sport = sport.rawValue
    self.type = type.rawValue
    self.url = url
    self.updateTime = updateTime
  }
}

/// Extends Race with computed values
extension Race {
  var location: RaceLocation {
    RaceLocation(
      country: country,
      province: province,
      city: city,
      district: district
    )
  }
  var distances: [RaceDistance] {
    categories.map {
      RaceDistance(
        category: RaceDistanceCategory(value: $0.distance),
        type: RaceDistanceType(rawValue: $0.type) ?? .inPerson
      )
    }
  }
}
