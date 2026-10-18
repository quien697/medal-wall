//
//  MedalDistanceFilter.swift
//  MedalWall
//
//  Created by Quien on 2026-09-07.
//

import Foundation

/// The distance narrowing applied to a medal collection.
///
/// Identity is the category's exact value and unit, which the synthesized `Hashable` takes
/// from `RaceDistanceCategory`. `10K` and `10 mi` are two options, and a custom distance of
/// exactly a standard value is that standard.
nonisolated enum MedalDistanceFilter: Hashable, Identifiable {
  case all
  case category(RaceDistanceCategory)

  // MARK: - Identifiable
  var id: String {
    switch self {
    case .all: "all"
    case .category(let category): "\(category.value)-\(category.unit.rawValue)"
    }
  }

  /// The chip label: `All`, or the distance's own name.
  ///
  /// A category names itself through `description`: a standard by its name, any other by
  /// its stored measurement.
  var label: String {
    switch self {
    case .all: .appLocalized("All")
    case .category(let category): category.description
    }
  }
}
