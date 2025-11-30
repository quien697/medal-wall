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
  private let repository: RaceRepository
  var race: Race
  
  init(race: Race, repository: RaceRepository = RaceRepository()) {
    self.race = race
    self.repository = repository
  }
  
  func attachContext(_ context: ModelContext) throws {
    repository.attachContext(context)
  }
  
  func deleteRace(_ race: Race) throws {
    try repository.deleteRace(race)
    try repository.save()
  }
}
