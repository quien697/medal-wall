//
//  RaceDistance.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation

/// Represents a specific marathon distance combined with its details
struct RaceDistance: Identifiable, Hashable, Comparable {
  let id: UUID = UUID()
  var category: RaceDistanceCategory
  var type: RaceDistanceType
  
  static var `default`: RaceDistance {
    RaceDistance(category: .full, type: .inPerson)
  }
  
  /// Display label for UI
  /// - Returns: `42km` for in-person, `Virtual 21km` for others
  var displayLabel: String {
    if type == .inPerson {
      return category.description
    }
    return "\(type.displayName) \(category.description)"
  }
  
  static func ==(lhs: RaceDistance, rhs: RaceDistance) -> Bool {
    lhs.category.value == rhs.category.value &&
    lhs.type == rhs.type
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(category.value)
    hasher.combine(type)
  }
  
  /// Comparable:
  /// Sort by type first, then distance (largest to smallest)
  static func < (lhs: RaceDistance, rhs: RaceDistance) -> Bool {
    if lhs.type.sortOrder != rhs.type.sortOrder {
      return lhs.type.sortOrder < rhs.type.sortOrder
    }
    return lhs.category.value > rhs.category.value
  }
}

// MARK: - Array Extensions
extension Array where Element == RaceDistance {
  
  /// Groups distances by type, sorted by type order
  /// - Returns: Array of tuples with type and its distances
  var groupedByType: [(type: RaceDistanceType, distances: [RaceDistance])] {
    return Dictionary(grouping: self.sorted()) { $0.type }
      .sorted { $0.key.sortOrder < $1.key.sortOrder }
      .map { (type: $0.key, distances: $0.value) }
  }
  
  /// All unique distance categories, sorted largest to smallest
  var uniqueCategories: [RaceDistanceCategory] {
    return Set(self.map(\.category))
      .sorted { $0.value > $1.value }
  }
  
  /// All unique types, sorted by sort order
  var uniqueTypes: [RaceDistanceType] {
    return Set(self.map(\.type))
      .sorted { $0.sortOrder < $1.sortOrder }
  }
}
