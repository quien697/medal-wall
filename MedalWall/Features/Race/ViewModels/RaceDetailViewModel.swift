//
//  RaceDetailViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-08.
//

import SwiftUI
import SwiftData

@Observable
class RaceDetailViewModel {
  let race: Race
  
  init(race: Race) {
    self.race = race
  }
  
  var distancesByType: [String: [RaceDistance]] {
    Dictionary(grouping: race.distances) { $0.type.displayName }
  }
}
