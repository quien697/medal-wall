//
//  RaceCategory.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class RaceCategory {
  @Attribute(.unique) var id: UUID
  var name: String
  var distance: Double
  var type: String
  
  @Relationship var race: Race
  
  init(
    id: UUID = UUID(),
    distance: RaceDistance,
    race: Race
  ) {
    self.id = id
    self.name = distance.category.description
    self.distance = distance.category.value
    self.type = distance.type.rawValue
    self.race = race
  }
}
