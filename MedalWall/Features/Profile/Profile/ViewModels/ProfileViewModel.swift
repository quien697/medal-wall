//
//  ProfileViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-04-18.
//

import SwiftUI

@Observable
final class ProfileViewModel {
  // MARK: - Data
  var medals: [Medal] = []

  // MARK: - State
  /// Starts `true`: the medals load as soon as the screen appears, and until then the
  /// statistics are not yet known.
  private(set) var isLoading = true
  /// Whether a load has succeeded, so a reload keeps the statistics on screen.
  private(set) var hasLoaded = false
  var error: AppError?
  /// Orders this screen's loads, so an older load's medals never replace a newer load's.
  private var loads = LoadSequence()

  // MARK: - Dependencies
  private let repository: any MedalRepository

  // MARK: - Init
  init(repository: (any MedalRepository)? = nil) {
    self.repository = repository ?? MedalFirestoreRepository()
  }

  // MARK: - Computed
  /// The medals the statistics come from: placeholders while bones stand in for them, the
  /// loaded medals otherwise.
  private var displayedMedals: [Medal] {
    isShowingSkeleton ? Medal.placeholders : medals
  }

  var totalMedals: Int { displayedMedals.count }
  var fullCount: Int { displayedMedals.fullCount }
  var halfCount: Int { displayedMedals.halfCount }
  var bestFullTime: String { displayedMedals.bestFullTime?.formattedHMS ?? "-" }
  var bestHalfTime: String { displayedMedals.bestHalfTime?.formattedHMS ?? "-" }

  /// Full Marathon achievement progress, from the loaded medals.
  var fullMarathonProgress: AchievementProgress { .compute(liveCount: fullCount) }

  /// Half Marathon achievement progress, from the loaded medals.
  var halfMarathonProgress: AchievementProgress { .compute(liveCount: halfCount) }

  /// Bones stand in for the statistics and achievements while the medals load, until a load
  /// first succeeds.
  var isShowingSkeleton: Bool {
    isLoading && !hasLoaded
  }

  // MARK: - Functions
  /// Loads all medals for the given user from Firestore, keeping the current ones if the fetch
  /// fails. Its medals are used unless a newer load's already are, and only the newest load
  /// presents an error or ends loading.
  func loadMedals(userId: String) async {
    let load = loads.begin()
    isLoading = true
    defer {
      if loads.isNewest(load) { isLoading = false }
    }

    do {
      let fetched = try await repository.fetchMedals(userId: userId)
      guard loads.shouldApply(load) else { return }
      medals = fetched
      hasLoaded = true
    } catch {
      guard loads.isNewest(load) else { return }
      self.error = .medalFetchFailed(error.localizedDescription)
    }
  }
}
