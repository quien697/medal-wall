//
//  AchievementProgress.swift
//  MedalWall
//
//  Created by Quien on 2026-07-14.
//

import Foundation

/// The displayed achievement state for one milestone track (e.g. Full Marathon).
struct AchievementProgress: Equatable {
  nonisolated let unlockedTier: AchievementTier?
  nonisolated let nextTier: AchievementTier?
  nonisolated let currentCount: Int
  nonisolated let isMaxed: Bool
}

extension AchievementProgress {
  /// Computes displayed progress from the user's persisted sticky milestone and
  /// the live medal count. The unlocked tier is taken from whichever of the two
  /// is higher, so newly-earned tiers show immediately even before the ratchet
  /// (`UserManager.refreshAchievementMilestones`) has persisted them; the
  /// persisted value alone is what protects a tier against later medal
  /// deletion. Progress toward the next tier always uses the live count.
  nonisolated static func compute(persistedMilestone: Int, liveCount: Int) -> AchievementProgress {
    let safeMilestone = max(0, persistedMilestone)
    let safeCount = max(0, liveCount)
    let effectiveMilestone = max(safeMilestone, safeCount)
    let unlockedTier = AchievementTier.allCases.last { $0.threshold <= effectiveMilestone }
    let nextTier = AchievementTier.allCases.first { $0.threshold > effectiveMilestone }

    return AchievementProgress(
      unlockedTier: unlockedTier,
      nextTier: nextTier,
      currentCount: safeCount,
      isMaxed: nextTier == nil
    )
  }

  /// Ratchets a persisted milestone upward to match the live count, if the live
  /// count has crossed a new tier threshold. Never decreases the persisted value.
  nonisolated static func ratchetedMilestone(persisted: Int, liveCount: Int) -> Int {
    let liveTierThreshold =
      AchievementTier.allCases.last { $0.threshold <= liveCount }?.threshold ?? 0
    return max(persisted, liveTierThreshold)
  }
}
