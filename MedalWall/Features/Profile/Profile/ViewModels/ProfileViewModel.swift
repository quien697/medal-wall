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
  var error: AppError?

  // MARK: - Dependencies
  private let repository: any MedalRepository

  // MARK: - Init
  init(repository: (any MedalRepository)? = nil) {
    self.repository = repository ?? MedalFirestoreRepository()
  }

  // MARK: - Computed
  var totalMedals: Int { medals.count }
  var fullCount: Int { medals.fullCount }
  var halfCount: Int { medals.halfCount }
  var bestFullTime: String { medals.bestFullTime?.formattedHMS ?? "-" }
  var bestHalfTime: String { medals.bestHalfTime?.formattedHMS ?? "-" }

  /// Full Marathon achievement progress, from the loaded medals.
  var fullMarathonProgress: AchievementProgress { .compute(liveCount: fullCount) }

  /// Half Marathon achievement progress, from the loaded medals.
  var halfMarathonProgress: AchievementProgress { .compute(liveCount: halfCount) }

  // MARK: - Functions
  /// Loads all medals for the given user from Firestore, keeping the current ones if the fetch fails.
  func loadMedals(userId: String) async {
    do {
      medals = try await repository.fetchMedals(userId: userId)
    } catch {
      self.error = .medalFetchFailed(error.localizedDescription)
    }
  }
}
