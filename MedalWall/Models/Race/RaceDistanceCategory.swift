//
//  RaceDistanceCategory.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
//

import SwiftUI

/// Represents standard or custom marathon distance categories,
/// used to display each distance with a distinct color.
enum RaceDistanceCategory: CustomStringConvertible, Hashable {
  case full
  case half
  case tenKM
  case fiveKM
  case custom(Double)

  /// The label shown in the UI, resolved against the stored distance unit preference.
  nonisolated var description: String {
    label(in: DistanceUnit.resolved())
  }

  /// The label for this category in a given unit.
  ///
  /// Presets are named rather than measured, identically in both units — converting them
  /// would produce labels no runner uses, since a 10K is never a "6.2mi race". Only a
  /// custom distance carries a measurement.
  nonisolated func label(
    in unit: DistanceUnit,
    defaults: UserDefaults = .standard
  ) -> String {
    switch self {
    case .full: .appLocalized("Full", defaults: defaults)
    case .half: .appLocalized("Half", defaults: defaults)
    case .tenKM: .appLocalized("10K", defaults: defaults)
    case .fiveKM: .appLocalized("5K", defaults: defaults)
    case .custom(let value): unit.formatted(kilometers: value, defaults: defaults)
    }
  }

  /// The numeric distance in kilometres used for Codable storage and sorting.
  nonisolated var value: Double {
    switch self {
    case .full: return 42.195
    case .half: return 21.0975
    case .tenKM: return 10
    case .fiveKM: return 5
    case .custom(let value): return value
    }
  }
}

extension RaceDistanceCategory {
  /// Reconstructs a category from its stored numeric value (kilometres).
  ///
  /// A small tolerance collapses values that round-trip across units onto the preset
  /// they measure — a marathon persisted as 26.2 miles arrives as 42.16481 km and
  /// would otherwise live as a separate chip from `.full`. 0.05 km is tight enough
  /// to reject 42.0 (off by 0.195) while still accepting 42.16481 (off by 0.030).
  nonisolated init(value: Double) {
    if abs(value - 42.195) < 0.05 {
      self = .full
    } else if abs(value - 21.0975) < 0.05 {
      self = .half
    } else if abs(value - 10) < 0.05 {
      self = .tenKM
    } else if abs(value - 5) < 0.05 {
      self = .fiveKM
    } else {
      self = .custom(value)
    }
  }

  /// The preset cases shown in the distance picker (excludes custom).
  static var standardCases: [RaceDistanceCategory] {
    [.full, .half, .tenKM, .fiveKM]
  }
}
