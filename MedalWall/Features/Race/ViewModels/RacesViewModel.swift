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
  var races: [Race]
  var filter: RaceFilter
  
  var visibleRaces: [Race] {
    let filtered = applyFilter(to: races)
    let searched = applySearch(on: filtered)
    return searched
  }
  
  init(
    races: [Race],
    filter: RaceFilter,
  ) {
    self.races = races
    self.filter = filter
  }
  
  func configure(context: ModelContext) {
    self.repository = RaceRepository(context: context)
  }
  
  func deleteRace(_ race: Race) throws {
    guard let repository else { throw AppError.contextNotAttached }
    
    try repository.deleteRace(race)
    try repository.save()
  }
  
  private func applyFilter(to races: [Race]) -> [Race] {
    return races.filter { race in
//      let distances = race.distances
//      
//      let typeMatch = {
//        guard !filter.selectedTypes.isEmpty else { return true }
//        return distances.contains { filter.selectedTypes.contains($0.type) }
//      }()
//      
//      let categoryMatch: Bool = {
//        guard !filter.selectedCategories.isEmpty else { return true }
//        return distances.contains { filter.selectedCategories.contains($0.category) }
//      }()
      
//      return typeMatch && categoryMatch
      return true
    }
  }
  
  private func applySearch(on races: [Race]) -> [Race] {
    let query = filter.searchQuery
    if query.isEmpty { return races }
    
    return races.filter { race in
      race.name.localizedStandardContains(query)
    }
  }
}
