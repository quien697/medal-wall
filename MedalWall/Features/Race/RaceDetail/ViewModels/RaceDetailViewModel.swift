//
//  RaceDetailViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-30.
//

import Foundation

@Observable
final class RaceDetailViewModel {
  // MARK: - Data
  var race: Race
  var editions: [RaceEdition] = []

  // MARK: - State
  /// Starts `true`: the editions load as soon as the screen appears, and until then an empty
  /// list is not yet known to be empty.
  var isLoading = true
  /// Whether a load of the editions has succeeded, so a reload keeps them on screen.
  private(set) var hasLoaded = false
  var error: AppError?

  // MARK: - Dependencies
  private let repository: any RaceRepository
  private let storageService: any PhotoStorage
  private let networkMonitor: any NetworkMonitor

  // MARK: - Init
  init(
    race: Race,
    repository: (any RaceRepository)? = nil,
    storageService: (any PhotoStorage)? = nil,
    networkMonitor: (any NetworkMonitor)? = nil
  ) {
    self.race = race
    self.repository = repository ?? RaceFirestoreRepository()
    self.storageService = storageService ?? StorageService()
    self.networkMonitor = networkMonitor ?? NWPathNetworkMonitor()
  }

  // MARK: - Computed
  /// Bones stand in for the editions while they load, until a load first succeeds.
  var isShowingSkeleton: Bool {
    isLoading && !hasLoaded
  }

  /// The editions the section shows: placeholders while bones stand in for them, the loaded
  /// editions otherwise.
  var displayedEditions: [RaceEdition] {
    isShowingSkeleton ? RaceEdition.placeholders : editions
  }

  // MARK: - Functions
  /// Whether the user may edit and delete the race: only its creator may, and no one while
  /// signed out.
  func canManageRace(userID: String?) -> Bool {
    race.createdBy == userID
  }

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

  /// Loads all editions for this race from Firestore, newest first.
  func loadEditions() async {
    isLoading = true
    defer { isLoading = false }

    do {
      editions = try await repository.fetchEditions(raceId: race.id)
        .sorted { $0.startDate > $1.startDate }
      hasLoaded = true
    } catch {
      self.error = .raceFetchFailed(error.localizedDescription)
    }
  }

  /// Deletes the race and all its editions from Firestore, then their logos from Storage.
  /// Offline, it reports `noInternetConnection` without deleting anything.
  func deleteRace() async {
    guard await networkMonitor.isConnected() else {
      error = .noInternetConnection
      return
    }

    do {
      let deletedEditions = try await repository.deleteRace(id: race.id)
      await storageService.deleteLogos(of: race, editions: deletedEditions)
    } catch {
      self.error = .raceDeleteFailed
    }
  }
}
