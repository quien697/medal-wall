//
//  RaceDetailViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-30.
//

import Foundation

@MainActor
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
  /// Orders the editions loads, so an older load's editions never replace a newer load's.
  private var editionsLoads = LoadSequence()
  /// Orders the reloads of the race, for the same reason.
  private var raceLoads = LoadSequence()

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

  /// Reloads the race data from Firestore to reflect any edits. Its race shows unless a newer
  /// reload's already has.
  func loadRace() async {
    let load = raceLoads.begin()
    do {
      let fetched = try await repository.fetchRace(id: race.id)
      guard raceLoads.shouldApply(load) else { return }
      if let fetched {
        race = fetched
      }
    } catch {
      // silently ignore — stale data is preferable to an error on dismiss
    }
  }

  /// Loads all editions for this race from Firestore, newest first. Its editions show unless a
  /// newer load's already have, and only the newest load presents an error or ends loading.
  func loadEditions() async {
    let load = editionsLoads.begin()
    isLoading = true
    defer {
      if editionsLoads.isNewest(load) { isLoading = false }
    }

    do {
      let fetched = try await repository.fetchEditions(raceId: race.id)
      guard editionsLoads.shouldApply(load) else { return }
      editions = fetched.sorted { $0.startDate > $1.startDate }
      hasLoaded = true
    } catch {
      guard editionsLoads.isNewest(load) else { return }
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
