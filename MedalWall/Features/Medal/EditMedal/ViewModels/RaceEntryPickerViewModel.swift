//
//  RaceEntryPickerViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-09-30.
//

import Foundation

@Observable
final class RaceEntryPickerViewModel {
  // MARK: - Properties
  private(set) var races: [Race] = []
  /// Each race's editions, keyed by race id and ordered newest first.
  private(set) var editions: [String: [RaceEdition]] = [:]
  /// Starts `true`: the picker loads as soon as it appears, and until then an empty list is
  /// not yet known to be empty.
  private(set) var isLoading = true
  var error: AppError?
  private let repository: any RaceRepository

  // MARK: - Init
  init(repository: (any RaceRepository)? = nil) {
    self.repository = repository ?? RaceFirestoreRepository()
  }

  // MARK: - Functions
  /// Loads every race and its editions, newest edition first.
  func load() async {
    isLoading = true
    defer { isLoading = false }

    do {
      let fetched = try await repository.fetchRaces()
      var loaded: [String: [RaceEdition]] = [:]
      for race in fetched {
        loaded[race.id] = try await repository.fetchEditions(raceId: race.id)
          .sorted { $0.year > $1.year }
      }
      races = fetched
      editions = loaded
    } catch {
      self.error = .raceFetchFailed(error.localizedDescription)
    }
  }
}
