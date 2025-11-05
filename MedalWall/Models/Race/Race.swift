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
  var dates: [Date]
  var location: RaceLocation
  var sport: Sport
  var type: RaceType
  var url: String?
  var distances: [RaceDistance]
  var updateTime: Date
  
  init(
    id: UUID = UUID(),
    name: String,
    photo: String? = nil,
    dates: [Date],
    location: RaceLocation,
    sport: Sport,
    type: RaceType,
    url: String? = nil,
    distances: [RaceDistance],
    updateTime: Date
  ) {
    self.id = id
    self.name = name
    self.photo = photo
    self.dates = dates
    self.location = location
    self.sport = sport
    self.type = type
    self.url = url
    self.distances = distances
    self.updateTime = updateTime
  }
}
