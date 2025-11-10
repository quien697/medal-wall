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
  
  func sortedEnumeratedByTypeAndDistance() -> [(offset: Int, element: RaceDistance)] {
    self.enumerated().sorted { lhs, rhs in
      let a = lhs.element
      let b = rhs.element
      if a.type != b.type {
        return a.type.rawValue < b.type.rawValue
      }
      return a.category.value > b.category.value
    }
  }
  
  //  func sortedByTypeAndDistance() -> [RaceDistance] {
  //    self
  //      .enumerated()
  //      .sorted { lhs, rhs in
  //        let a = lhs.element
  //        let b = rhs.element
  //
  //        // 1️⃣ Sort by type first
  //        if a.type != b.type {
  //          return a.type.rawValue < b.type.rawValue
  //        }
  //
  //        // 2️⃣ Then sort by distance (larger first)
  //        return a.category.value > b.category.value
  //      } as! [RaceDistance]
  //  }
}
