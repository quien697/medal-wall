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
  var date: Date
  var location: RaceLocation
  var url: String?
  var isOfficial: Bool
  
  @Relationship(deleteRule: .cascade, inverse: \RaceCategory.race)
  var categories: [RaceCategory] = []
  
  init(
    id: UUID,
    name: String,
    date: Date,
    location: RaceLocation,
    url: String? = nil,
    isOfficial: Bool = true,
    categories: [RaceCategory]
  ) {
    self.id = id
    self.name = name
    self.date = date
    self.location = location
    self.url = url
    self.isOfficial = isOfficial
    self.categories = categories
  }
}
