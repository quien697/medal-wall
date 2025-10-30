//
//  RaceCategory.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation
import SwiftData

@Model
final class RaceCategory {
  @Attribute(.unique) var id: UUID
  @Relationship var race: Race
  var distance: RaceDistance
  var name: String?
  var type: RaceCategoryType
  
  init(
    id: UUID,
    race: Race,
    distance: RaceDistance,
    name: String? = nil,
    type: RaceCategoryType = .inPerson,
  ) {
    self.id = id
    self.race = race
    self.distance = distance
    self.name = name
    self.type = type
  }
}
