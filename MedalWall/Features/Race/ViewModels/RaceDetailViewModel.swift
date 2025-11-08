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
  
  var categoriesByType: [String: [RaceCategory]] {
    Dictionary(grouping: race.categories) { $0.type }
  }
}
