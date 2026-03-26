//
//  RaceDetailViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-30.
//

import SwiftUI
import SwiftData

@Observable
final class RaceDetailViewModel {
  private var repository: RaceRepository?
  var race: Race
  
  init(race: Race) {
    self.race = race
  }
  
  func configure(context: ModelContext) {
    self.repository = RaceRepository(context: context)
  }
  
  func deleteRace(_ race: Race) throws {
    guard let repository else { throw AppError.contextNotAttached }
    
    try repository.deleteRace(race)
    try repository.save()
  }
}
