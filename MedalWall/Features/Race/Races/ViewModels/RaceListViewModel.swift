//
//  RaceListViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-21.
//

import SwiftUI
import SwiftData

@Observable
final class RaceListViewModel {
  private var repository: RaceRepository?
  // Search
  var searchText: String = ""
  // Filter
  var selectedTypes: Set<RaceDistanceType> = []
  var selectedCategories: Set<RaceDistanceCategory> = []
  // Sort
  var sortOrder: [SortDescriptor<Race>] = RaceSort.name.order
  // Predicate for SwiftData Query - handles search only
  var predicate: Predicate<Race> {
    #Predicate<Race> { race in
      searchText.isEmpty || race.name.localizedStandardContains(searchText)
    }
  }
  
  /// In-memory filtering for complex filters (types and categories)
  func filteredRaces(_ races: [Race]) -> [Race] {
    var result = races
    
    // Filter by types if any are selected
    if !selectedTypes.isEmpty {
      result = result.filter { race in
        race.editions.contains { edition in
          edition.distances.contains { distance in
            selectedTypes.contains(distance.type)
          }
        }
      }
    }
    
    // Filter by categories if any are selected
    if !selectedCategories.isEmpty {
      result = result.filter { race in
        race.editions.contains { edition in
          edition.distances.contains { distance in
            selectedCategories.contains(distance.category)
          }
        }
      }
    }
    
    return result
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
