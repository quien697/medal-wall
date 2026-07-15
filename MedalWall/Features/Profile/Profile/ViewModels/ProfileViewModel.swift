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

  // MARK: - Dependencies
  private let repository = MedalFirestoreRepository()

  // MARK: - Computed
  var totalMedals: Int { medals.count }
  var fullCount: Int { medals.fullCount }
  var halfCount: Int { medals.halfCount }
  var bestFullTime: String { medals.bestFullTime?.formattedHMS ?? "-" }
  var bestHalfTime: String { medals.bestHalfTime?.formattedHMS ?? "-" }

  // MARK: - Functions
  /// Loads all medals for the given user from Firestore.
  func loadMedals(userId: String) async {
    medals = (try? await repository.fetchMedals(userId: userId)) ?? []
  }

  /// Computes Full Marathon achievement progress from the loaded medals and the given user's persisted milestone.
  func fullMarathonProgress(user: User?) -> AchievementProgress {
    AchievementProgress.compute(
      persistedMilestone: user?.highestFullMilestone ?? 0, liveCount: fullCount)
  }

  /// Computes Half Marathon achievement progress from the loaded medals and the given user's persisted milestone.
  func halfMarathonProgress(user: User?) -> AchievementProgress {
    AchievementProgress.compute(
      persistedMilestone: user?.highestHalfMilestone ?? 0, liveCount: halfCount)
  }
}
