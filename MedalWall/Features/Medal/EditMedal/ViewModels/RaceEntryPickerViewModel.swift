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
  ///
  /// Every race's editions are fetched at once, so the wait is one round trip rather than one
  /// per race. A race whose editions fail to load is still listed and the failure is reported,
  /// so one bad fetch does not hide every other race.
  func load() async {
    isLoading = true
    defer { isLoading = false }

    let fetched: [Race]
    do {
      fetched = try await repository.fetchRaces()
    } catch {
      self.error = .raceFetchFailed(error.localizedDescription)
      return
    }

    var loaded: [String: [RaceEdition]] = [:]
    await withTaskGroup(of: (String, Result<[RaceEdition], AppError>).self) { group in
      for raceId in fetched.map(\.id) {
        // A strong `self`: a child task cannot outlive this call, so it cannot hold a cycle.
        group.addTask {
          (raceId, await self.fetchEditions(raceId: raceId))
        }
      }
      for await (raceId, result) in group {
        switch result {
        case .success(let editions):
          loaded[raceId] = editions
        case .failure(let error):
          self.error = error
        }
      }
    }
    races = fetched
    editions = loaded
  }

  /// Fetches one race's editions, newest first.
  private func fetchEditions(raceId: String) async -> Result<[RaceEdition], AppError> {
    do {
      let editions = try await repository.fetchEditions(raceId: raceId)
      return .success(editions.sorted { $0.year > $1.year })
    } catch {
      return .failure(.raceFetchFailed(error.localizedDescription))
    }
  }
}
