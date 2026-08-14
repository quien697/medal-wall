//
//  RaceDistance.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation

/// Represents a specific marathon distance combined with its details
struct RaceDistance: Identifiable, Hashable, Comparable, Codable {
  let id = UUID()
  var category: RaceDistanceCategory
  var type: RaceDistanceType

  /// Fallback used when no distance has been selected yet.
  static var `default`: RaceDistance {
    RaceDistance(category: .full, type: .inPerson)
  }

  /// `"Full"` for in-person, `"Virtual Half"` for other types.
  var displayLabel: String {
    if type == .inPerson {
      return category.description
    }
    return "\(type.displayName) \(category.description)"
  }

  static func == (lhs: RaceDistance, rhs: RaceDistance) -> Bool {
    lhs.category.value == rhs.category.value && lhs.type == rhs.type
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

extension RaceDistance {

  private enum CodingKeys: String, CodingKey {
    case value
    case type
  }

  /// Decodes from `{ "value": Double, "type": String }` — the Firestore storage format.
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let value = try container.decode(Double.self, forKey: .value)
    let typeRaw = try container.decode(String.self, forKey: .type)
    self.category = RaceDistanceCategory(value: value)
    self.type = RaceDistanceType(rawValue: typeRaw) ?? .inPerson
  }

  /// Encodes to `{ "value": Double, "type": String }` — the Firestore storage format.
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(category.value, forKey: .value)
    try container.encode(type.rawValue, forKey: .type)
  }
}
