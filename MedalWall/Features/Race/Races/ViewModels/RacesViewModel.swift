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
  /// Starts `true`: the screen loads as soon as it appears, and until then an empty list is
  /// not yet known to be empty.
  var isLoading = true
  /// Whether a load has succeeded, so a reload keeps the races on screen.
  private(set) var hasLoaded = false
  var error: AppError?
  /// Numbers each load, so a fetch that returns after a newer load has started leaves the
  /// newer load's races, error and loading state alone. Loads are never cancelled, so they can
  /// overlap.
  private var loadGeneration = 0

  // MARK: - Dependencies
  private let repository: any RaceRepository

  // MARK: - Init
  init(repository: (any RaceRepository)? = nil) {
    self.repository = repository ?? RaceFirestoreRepository()
  }

  // MARK: - Computed
  /// The races to show, sorted by name, each with `editionCount` clamped to zero or more.
  var sortedRaces: [Race] {
    races
      .sorted { $0.name.localizedCompare($1.name) == .orderedAscending }
      .withClampedEditionCounts
  }

  /// Bones stand in for the races while they load, until a load first succeeds.
  var isShowingSkeleton: Bool {
    isLoading && !hasLoaded
  }

  /// The races the list shows: placeholders while bones stand in for them, the sorted races
  /// otherwise.
  var displayedRaces: [Race] {
    isShowingSkeleton ? Race.placeholders : sortedRaces
  }

  // MARK: - Functions
  /// Loads all races from Firestore. A load that is no longer the newest changes nothing.
  func loadRaces() async {
    loadGeneration += 1
    let generation = loadGeneration
    isLoading = true
    defer {
      if generation == loadGeneration { isLoading = false }
    }

    do {
      let fetched = try await repository.fetchRaces()
      guard generation == loadGeneration else { return }
      races = fetched
      hasLoaded = true
    } catch {
      guard generation == loadGeneration else { return }
      self.error = .raceFetchFailed(error.localizedDescription)
    }
  }
}
