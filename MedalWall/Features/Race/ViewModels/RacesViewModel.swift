//
//  RacesViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-21.
//

import SwiftUI
import SwiftData

@Observable
final class RacesViewModel {
  private var repository: RaceRepository?
  // Search
  var searchText: String = ""
  // Sort
  var sortOrder: [SortDescriptor<Race>] = RaceSort.name.order
  
  var predicate: Predicate<Race> {
    #Predicate<Race> { race in
      if searchText.isEmpty {
        true
      } else {
        race.name.localizedStandardContains(searchText)
      }
    }
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
