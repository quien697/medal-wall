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
  /// Loads all medals for the given user from Firestore, keeping the current ones if the fetch fails.
  func loadMedals(userId: String) async {
    defer { isLoading = false }
    isLoading = true

    do {
      medals = try await repository.fetchMedals(userId: userId)
      hasLoaded = true
    } catch {
      self.error = .medalFetchFailed(error.localizedDescription)
    }
  }
}
