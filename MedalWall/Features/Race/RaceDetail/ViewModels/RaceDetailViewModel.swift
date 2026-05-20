//
//  RaceDetailViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-30.
//

import Foundation

@Observable
final class RaceDetailViewModel {
  // MARK: - Properties
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
