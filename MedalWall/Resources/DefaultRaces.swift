//
//  DefaultRaces.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation
import SwiftData

enum DefaultRaces {
  
  static func all() -> [Race] {
    let taipei = Race(
      id: UUID(),
      name: "Taipei Marathon 2024",
      date: Date(),
      location: RaceLocation(
        country: "Taiwan",
        city: "Taipei"
      ),
      url: "https://taipeicitymarathon.com",
      categories: []
    )
    taipei.categories = [
      RaceCategory(id: UUID(), race: taipei, distance: .fullMarathon, name: "Full Marathon"),
      RaceCategory(id: UUID(), race: taipei, distance: .halfMarathon, name: "Falf Marathon"),
    ]
    
    let vancouver = Race(
      id: UUID(),
      name: "BMO Vancouver Marathon 2024",
      date: Date(),
      location: RaceLocation(
        country: "Canada",
        province: "BC",
        city: "Vancouver"
      ),
      url: "https://bmovanmarathon.ca/",
      categories: []
    )
    vancouver.categories = [
      RaceCategory(id: UUID(), race: vancouver, distance: .fullMarathon, name: "Full Marathon"),
      RaceCategory(id: UUID(), race: vancouver, distance: .halfMarathon, name: "Falf Marathon"),
    ]
    
    return [taipei, vancouver]
  }
}
