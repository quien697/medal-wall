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

  // MARK: - Filter
  var searchText: String = ""

  // MARK: - Dependencies
  private let repository: any RaceRepository
  private let storageService: any PhotoStorage
  private let networkMonitor: any NetworkMonitor

  // MARK: - Init
  init(
    repository: (any RaceRepository)? = nil,
    storageService: (any PhotoStorage)? = nil,
    networkMonitor: (any NetworkMonitor)? = nil
  ) {
    self.repository = repository ?? RaceFirestoreRepository()
    self.storageService = storageService ?? StorageService()
    self.networkMonitor = networkMonitor ?? NWPathNetworkMonitor()
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

  /// Bones stand in for the races while they load, until a load first succeeds.
  var isShowingSkeleton: Bool {
    isLoading && !hasLoaded
  }

  /// The races the list shows: placeholders while bones stand in for them, the searched races
  /// otherwise.
  var displayedRaces: [Race] {
    isShowingSkeleton ? Race.placeholders : filteredRaces
  }

  // MARK: - Functions
  /// Loads all races from Firestore.
  func loadRaces() async {
    isLoading = true
    defer { isLoading = false }

    do {
      races = try await repository.fetchRaces()
      hasLoaded = true
    } catch {
      self.error = .raceFetchFailed(error.localizedDescription)
    }
  }

  /// Deletes the race from Firestore and removes it from the local list, then deletes its
  /// logos from Storage. Offline, it reports `noInternetConnection` without deleting anything.
  func deleteRace(_ race: Race) async {
    guard await networkMonitor.isConnected() else {
      error = .noInternetConnection
      return
    }

    do {
      let deletedEditions = try await repository.deleteRace(id: race.id)
      races.removeAll { $0.id == race.id }
      await storageService.deleteLogos(of: race, editions: deletedEditions)
    } catch {
      self.error = .raceDeleteFailed
    }
  }
}
