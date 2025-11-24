//
//  RacesFactory.swift
//  MedalWall
//
//  Created by Quien on 2025-11-24.
//

import Foundation
import SwiftUI

enum RaceFactory {
  static var sampleData: [Race] {
    taipei.categories = [
      .init(distance: RaceDistance(category: .full, type: .inPerson), race: taipei),
      .init(distance: RaceDistance(category: .half, type: .inPerson), race: taipei),
      .init(distance: RaceDistance(category: .full, type: .virtual), race: taipei)
    ]
    tokyo.categories = [
      .init(distance: RaceDistance(category: .`10K`, type: .inPerson), race: tokyo),
      .init(distance: RaceDistance(category: .`5K`, type: .inPerson), race: tokyo),
    ]
    vancouver.categories = [
      .init(distance: RaceDistance(category: .full, type: .virtual), race: vancouver),
      .init(distance: RaceDistance(category: .half, type: .virtual), race: vancouver),
      .init(distance: RaceDistance(category: .`10K`, type: .virtual), race: vancouver),
      .init(distance: RaceDistance(category: .`5K`, type: .virtual), race: vancouver),
    ]
    
    return [taipei, tokyo, vancouver]
  }
  
  static let taipei: Race = .init(
    name: "Taipei Marathon",
    date: DateComponents(calendar: .current, year: 2025, month: 12, day: 21).date!,
    location: RaceLocation(
      country: "Taiwan",
      city: "Taipei"
    )
  )
  
  static let tokyo: Race = .init(
    name: "Tokyo Marathon",
    date: DateComponents(calendar: .current, year: 2026, month: 3, day: 1).date!,
    location: RaceLocation(
      country: "Japan",
      city: "Tokyo"
    )
  )
  
  static let vancouver: Race = .init(
    name: "MBO Vancouver Marathon",
    date: DateComponents(calendar: .current, year: 2026, month: 3, day: 1).date!,
    location: RaceLocation(
      country: "Canada",
      province: "BC",
      city: "Vancouver"
    )
  )
}
