//
//  RaceDistance.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation

/// Represents a specific marathon distance combined with its details
struct RaceDistance: Identifiable, Hashable {
  let id: UUID = UUID()
  var category: RaceDistanceCategory
  var type: RaceDistanceType
  
  static var `default`: RaceDistance {
    RaceDistance(category: .full, type: .inPerson)
  }
}

extension Array where Element == RaceDistance {
  
  func sortedByDistance() -> [RaceDistance] {
    self.sorted { $0.category.value > $1.category.value }
  }
  
  func sortedByTypeAndDistance() -> [RaceDistance] {
    self.sorted {
      if $0.type != $1.type {
        return $0.type.rawValue < $1.type.rawValue
      }
      return $0.category.value > $1.category.value
    }
  }
}
