//
//  AchievementProgress.swift
//  MedalWall
//
//  Created by Quien on 2026-07-14.
//

import Foundation

/// The displayed achievement state for one milestone track (e.g. Full Marathon).
struct AchievementProgress: Equatable {
  let unlockedTier: AchievementTier?
  let nextTier: AchievementTier?
  let currentCount: Int
  let isMaxed: Bool
}

extension AchievementProgress {
  /// Computes displayed progress from the live medal count: the unlocked tier, the
  /// next tier and progress toward it all follow the count, so deleting medals lowers
  /// the tier as adding them raises it.
  static func compute(liveCount: Int) -> AchievementProgress {
    let safeCount = max(0, liveCount)
    let unlockedTier = AchievementTier.allCases.last { $0.threshold <= safeCount }
    let nextTier = AchievementTier.allCases.first { $0.threshold > safeCount }

    return AchievementProgress(
      unlockedTier: unlockedTier,
      nextTier: nextTier,
      currentCount: safeCount,
      isMaxed: nextTier == nil
    )
  }

  /// How far the live count has come toward the tier the meter shows: the next tier
  /// while one remains, the unlocked tier once the track is maxed.
  ///
  /// Clamped to `0...1` so a count past the final threshold, or a corrupt one, cannot
  /// overrun the track.
  var progressFraction: Double {
    guard let target = nextTier ?? unlockedTier, target.threshold > 0 else { return 0 }

    return min(1, max(0, Double(currentCount) / Double(target.threshold)))
  }
}
