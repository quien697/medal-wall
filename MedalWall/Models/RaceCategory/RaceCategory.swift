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
    self.type = distance.type.displayName
    self.race = race
  }
}

/// Extends RaceCategory with computed values
extension RaceCategory {
  var raceDistanceCategoryGroup: RaceDistanceCategoryGroup {
    switch distance {
    case ..<5: return .fun
    case 5..<15: return .mini
    case 15..<25: return .half
    case 25..<40: return .long
    case 40..<45: return .full
    default: return .ultra
    }
  }
  
  var color: Color {
    raceDistanceCategoryGroup.color
  }
}
