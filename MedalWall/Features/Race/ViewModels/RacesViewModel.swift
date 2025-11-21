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
  var races: [Race]
  var filter: RaceFilter
  
  var visibleRaces: [Race] {
    let filtered = applyFilter(to: races)
    let searched = applySearch(on: filtered)
    return searched
  }
  
  init(races: [Race], filter: RaceFilter) {
    self.races = races
    self.filter = filter
  }
  
  private func applyFilter(to races: [Race]) -> [Race] {
    return races.filter { race in
      let distances = race.distances
      
      let typeMatch = {
        guard !filter.selectedTypes.isEmpty else { return true }
        return distances.contains { filter.selectedTypes.contains($0.type) }
      }()
      
      let categoryMatch: Bool = {
        guard !filter.selectedCategories.isEmpty else { return true }
        return distances.contains { filter.selectedCategories.contains($0.category) }
      }()
      
      return typeMatch && categoryMatch
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
