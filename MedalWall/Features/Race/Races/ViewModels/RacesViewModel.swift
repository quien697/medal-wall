//
//  RacesViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-21.
//

import Foundation

@Observable
final class RacesViewModel {
  // MARK: - Properties
  var races: [Race] = []
  var isLoading = false
  var error: AppError?
  var searchText: String = ""
  var selectedTypes: Set<RaceDistanceType> = []
  var selectedCategories: Set<RaceDistanceCategory> = []
  var selectedSort: RaceSort = .name
  
  private let repository = RaceFirestoreRepository()
  
  // MARK: - Computed
  var filteredRaces: [Race] {
    let searched = searchText.isEmpty
    ? races
    : races.filter { $0.name.localizedStandardContains(searchText) }
    return searched.sorted(by: selectedSort.comparator)
  }
  
  // MARK: - Functions
  
  /// Loads all races created by the given user from Firestore.
  func loadRaces(uid: String) async {
    isLoading = true
    defer { isLoading = false }
    
    do {
      races = try await repository.fetchRaces()
    } catch {
      self.error = .raceFetchFailed(error.localizedDescription)
    }
  }
  
  /// Deletes the race from Firestore and removes it from the local list.
  func deleteRace(_ race: Race) async {
    do {
      try await repository.deleteRace(id: race.id)
      races.removeAll { $0.id == race.id }
    } catch {
      self.error = .raceDeleteFailed
    }
  }
}
