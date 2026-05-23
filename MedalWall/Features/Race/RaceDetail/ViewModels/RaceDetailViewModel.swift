//
//  RaceDetailViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-30.
//

import Foundation

@Observable
final class RaceDetailViewModel {
  var race: Race
  var editions: [RaceEdition] = []
  var isLoading = false
  var error: AppError?
  private let repository = RaceFirestoreRepository()
  
  // MARK: - Init
  init(race: Race) {
    self.race = race
  }
  
  // MARK: - Functions
  /// Reloads the race data from Firestore to reflect any edits.
  func loadRace() async {
    do {
      if let updated = try await repository.fetchRace(id: race.id) {
        race = updated
      }
    } catch {
      // silently ignore — stale data is preferable to an error on dismiss
    }
  }
  
  /// Loads all editions for this race from Firestore.
  func loadEditions() async {
    isLoading = true
    defer { isLoading = false }
    
    do {
      editions = try await repository.fetchEditions(raceId: race.id)
    } catch {
      self.error = .raceFetchFailed(error.localizedDescription)
    }
  }
  
  /// Deletes the race and all its editions from Firestore.
  func deleteRace() async {
    do {
      try await repository.deleteRace(id: race.id)
    } catch {
      self.error = .raceDeleteFailed
    }
  }
}
