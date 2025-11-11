//
//  Array+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2025-11-09.
//

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
