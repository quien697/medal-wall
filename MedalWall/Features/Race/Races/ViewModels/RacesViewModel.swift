//
//  RacesViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-21.
//

import Foundation

@MainActor
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
  /// Orders this screen's loads, so an older load's races never replace a newer load's.
  private var loads = LoadSequence()

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
  /// Loads all races from Firestore. Its races show unless a newer load's already have, and
  /// only the newest load presents an error or ends loading.
  func loadRaces() async {
    let load = loads.begin()
    isLoading = true
    defer {
      if loads.isNewest(load) { isLoading = false }
    }

    do {
      let fetched = try await repository.fetchRaces()
      guard loads.shouldApply(load) else { return }
      races = fetched
      hasLoaded = true
    } catch {
      guard loads.isNewest(load) else { return }
      self.error = .raceFetchFailed(error.localizedDescription)
    }
  }
}
