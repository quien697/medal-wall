//
//  MedalDistanceFilter.swift
//  MedalWall
//
//  Created by Quien on 2026-09-07.
//

import Foundation

/// The distance narrowing applied to a medal collection.
///
/// Identity follows the distance a category *measures*, never the case that spells it, so
/// a custom 42.195 and `.full` are one option rather than two. `RaceDistance` defines its
/// own `==` and `hash` over `category.value` for the same reason — a silently split "Full"
/// bucket would show one distance as two chips.
nonisolated enum MedalDistanceFilter: Hashable, Identifiable {
  case all
  case category(RaceDistanceCategory)

  // MARK: - Identifiable
  var id: String {
    switch self {
    case .all: "all"
    case .category(let category): "\(category.value)"
    }
  }

  // MARK: - Hashable
  /// Compares by measured distance, so equal distances are one option.
  static func == (lhs: MedalDistanceFilter, rhs: MedalDistanceFilter) -> Bool {
    switch (lhs, rhs) {
    case (.all, .all):
      true
    case (.category(let lhsCategory), .category(let rhsCategory)):
      lhsCategory.value == rhsCategory.value
    case (.all, .category), (.category, .all):
      false
    }
  }

  /// Hashes the measured distance so it agrees with `==`.
  func hash(into hasher: inout Hasher) {
    switch self {
    case .all: hasher.combine("all")
    case .category(let category): hasher.combine(category.value)
    }
  }
}
