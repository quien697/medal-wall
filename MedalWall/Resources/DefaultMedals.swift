//
//  DefaultMedals.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation
import SwiftData

enum DefaultMedals {
  
  static func all(for user: User, races: [Race]) -> [Medal] {
    guard
      let taipeiFull = races
        .first(where: { $0.name.contains("Taipei") })?
        .categories.first(where: { $0.name?.contains("Full") ?? false }),
      
        let vancouverHalf = races
        .first(where: { $0.name.contains("Vancouver") })?
        .categories.first(where: { $0.name?.contains("Half") ?? false })
    else {
      return []
    }
    
    let medal1 = Medal(
      id: UUID(),
      user: user,
      category: taipeiFull,
      result: "3:45:22",
      medalPhoto: "taipei_marathon_2024_medal.jpg",
      eventPhotos: [],
      note: "Sunny day with perfect pace."
    )
    
    let medal2 = Medal(
      id: UUID(),
      user: user,
      category: vancouverHalf,
      result: "1:42:10",
      medalPhoto: "vancouver_marathon_2024_medal.jpg",
      eventPhotos: [],
      note: "Beautiful route along Stanley Park."
    )
    
    return [medal1, medal2]
  }
}
