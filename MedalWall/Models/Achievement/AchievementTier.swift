//
//  AchievementTier.swift
//  MedalWall
//
//  Created by Quien on 2026-07-14.
//

import Foundation

/// Milestone tiers for marathon completion-count achievements, shared by the
/// Full Marathon and Half Marathon tracks.
enum AchievementTier: Int, CaseIterable {
  case firstFinish = 1
  case hatTrick = 3
  case highFive = 5
  case perfectTen = 10
  case quarterCentury = 25
  case halfCentury = 50
  case centurion = 100

  /// Display name shown in the achievement row.
  nonisolated var name: String {
    switch self {
    case .firstFinish: return .appLocalized("First Finish")
    case .hatTrick: return .appLocalized("Hat Trick")
    case .highFive: return .appLocalized("High Five")
    case .perfectTen: return .appLocalized("Perfect Ten")
    case .quarterCentury: return .appLocalized("Quarter Century")
    case .halfCentury: return .appLocalized("Half Century")
    case .centurion: return .appLocalized("Centurion")
    }
  }

  /// The medal count required to reach this tier.
  nonisolated var threshold: Int { rawValue }
}
