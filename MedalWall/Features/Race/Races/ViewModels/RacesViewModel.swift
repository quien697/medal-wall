//
//  RacesViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-21.
//

import Foundation

@Observable
final class RacesViewModel {
  // MARK: - Data
  var races: [Race] = []

  // MARK: - State
  var isLoading = false
  var error: AppError?

  // MARK: - Filter
  var searchText: String = ""

  // MARK: - Dependencies
  private let repository: any RaceRepository

  // MARK: - Init
  init(repository: (any RaceRepository)? = nil) {
    self.repository = repository ?? RaceFirestoreRepository()
  }

  // MARK: - Computed
  /// The races to show, searched and sorted, each with `editionCount` clamped to zero or
  /// more: the count is maintained server-side, so a corrupt value must not reach a row and
  /// render as "-1 editions".
  var filteredRaces: [Race] {
    let searched =
      searchText.isEmpty
      ? races
      : races.filter { $0.name.localizedStandardContains(searchText) }
    return
      searched
      .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
      .map { race in
        var clamped = race
        clamped.editionCount = max(0, race.editionCount)
        return clamped
      }
  }

  // MARK: - Functions
  /// Loads all races from Firestore.
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
