//
//  RacesViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-21.
//

import Foundation

@Observable
final class RacesViewModel {
  // MARK: - State
  var races: [Race] = []
  var isLoading = false
  var error: AppError?
  
  // MARK: - Filter
  var searchText: String = ""
  
  // MARK: - Dependencies
  private let repository = RaceFirestoreRepository()
  
  // MARK: - Computed
  var filteredRaces: [Race] {
    let searched = searchText.isEmpty
    ? races
    : races.filter { $0.name.localizedStandardContains(searchText) }
    return searched.sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
  }
  
  // MARK: - Functions
  /// Loads all races created by the given user from Firestore.
  func loadRaces() async {
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
