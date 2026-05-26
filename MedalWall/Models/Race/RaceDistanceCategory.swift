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

  /// Defines display name for UI
  nonisolated
    var description: String
  {
    switch self {
    case .full: return "42km"
    case .half: return "21km"
    case .tenKM: return "10km"
    case .fiveKM: return "5km"
    case .custom(let value):
      if value.truncatingRemainder(dividingBy: 1) == 0 {
        return "\(Int(value))km"
      } else {
        return "\(value)km"
      }
    }
  }

  /// The numeric distance in kilometres used for Codable storage and sorting.
  nonisolated
    var value: Double
  {
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
  nonisolated
    init(value: Double)
  {
    switch value {
    case 42.195: self = .full
    case 21.0975: self = .half
    case 10: self = .tenKM
    case 5: self = .fiveKM
    default: self = .custom(value)
    }
  }

  /// The preset cases shown in the distance picker (excludes custom).
  static var standardCases: [RaceDistanceCategory] {
    [.full, .half, .tenKM, .fiveKM]
  }
}
