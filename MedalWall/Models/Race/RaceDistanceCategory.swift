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
  /// Reconstructs a category from its stored numeric value (kilometres) exactly.
  ///
  /// This is what `RaceDistance` decode uses. It does not tolerate near-preset values,
  /// because decode has to preserve whatever was actually saved — collapsing here would
  /// silently rewrite a genuine custom course into a preset every time a medal or race
  /// round-trips through Firestore. Collapsing near-preset values for display is
  /// `nearestPreset(forValue:)`'s job, not this initializer's.
  nonisolated init(value: Double) {
    switch value {
    case 42.195: self = .full
    case 21.0975: self = .half
    case 10: self = .tenKM
    case 5: self = .fiveKM
    default: self = .custom(value)
    }
  }

  /// The preset this measured value is close enough to be presented as, collapsing unit
  /// round-trip drift onto the preset it measures — a marathon persisted as 26.2 miles
  /// arrives as 42.16481 km and would otherwise live as a separate chip from `.full`.
  /// 0.05 km is tight enough to reject 42.0 (off by 0.195) while still accepting
  /// 42.16481 (off by 0.030).
  ///
  /// Used only where distances are grouped or filtered for display — the medal
  /// collection's chips and its personal-best derivation — never for decode.
  nonisolated static func nearestPreset(forValue value: Double) -> RaceDistanceCategory {
    if abs(value - RaceDistanceCategory.full.value) < 0.05 {
      return .full
    } else if abs(value - RaceDistanceCategory.half.value) < 0.05 {
      return .half
    } else if abs(value - RaceDistanceCategory.tenKM.value) < 0.05 {
      return .tenKM
    } else if abs(value - RaceDistanceCategory.fiveKM.value) < 0.05 {
      return .fiveKM
    } else {
      return .custom(value)
    }
  }

  /// The preset cases shown in the distance picker (excludes custom).
  static var standardCases: [RaceDistanceCategory] {
    [.full, .half, .tenKM, .fiveKM]
  }
}
