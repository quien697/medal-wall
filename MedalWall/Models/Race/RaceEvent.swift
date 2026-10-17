//
//  RaceEvent.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation

/// An event a race offers, or the one a medal was earned in: a distance and how it was run.
struct RaceEvent: Identifiable, Hashable, Comparable, Codable {
  let id = UUID()
  var category: RaceDistanceCategory
  var type: RaceDistanceType

  /// Fallback used when no distance has been selected yet.
  static var `default`: RaceEvent {
    RaceEvent(category: .full, type: .inPerson)
  }

  /// `"Full"` for in-person, `"Virtual Half"` for other types.
  var displayLabel: String {
    if type == .inPerson {
      return category.description
    }
    return "\(type.displayName) \(category.description)"
  }

  static func == (lhs: RaceEvent, rhs: RaceEvent) -> Bool {
    lhs.category == rhs.category && lhs.type == rhs.type
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(category)
    hasher.combine(type)
  }

  /// Sorts by type, then by real length from longest to shortest, then kilometres before
  /// miles where two real lengths are equal, so the order never depends on what Firestore
  /// returned.
  static func < (lhs: RaceEvent, rhs: RaceEvent) -> Bool {
    if lhs.type.sortOrder != rhs.type.sortOrder {
      return lhs.type.sortOrder < rhs.type.sortOrder
    }
    if lhs.category.kilometers != rhs.category.kilometers {
      return lhs.category.kilometers > rhs.category.kilometers
    }
    return lhs.category.unit == .kilometers && rhs.category.unit == .miles
  }
}

extension RaceEvent {

  private enum CodingKeys: String, CodingKey {
    case kind
    case value
    case unit
    case type
  }

  /// The only kind of event this version reads and writes.
  private static let distanceKind = "distance"

  /// Decodes from `{ kind, value, unit, type }` — the Firestore storage format. Another
  /// `kind`, or a missing or unknown `unit`, is an error rather than a guess.
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    let kind = try container.decode(String.self, forKey: .kind)
    guard kind == Self.distanceKind else {
      throw DecodingError.dataCorruptedError(
        forKey: .kind,
        in: container,
        debugDescription: "Unsupported event kind \(kind)"
      )
    }
    let value = try container.decode(Double.self, forKey: .value)
    let unitRaw = try container.decode(String.self, forKey: .unit)
    guard let unit = DistanceUnit(rawValue: unitRaw) else {
      throw DecodingError.dataCorruptedError(
        forKey: .unit,
        in: container,
        debugDescription: "Unknown distance unit \(unitRaw)"
      )
    }
    let typeRaw = try container.decode(String.self, forKey: .type)
    self.category = RaceDistanceCategory(value: value, unit: unit)
    self.type = RaceDistanceType(rawValue: typeRaw) ?? .inPerson
  }

  /// Encodes to `{ kind, value, unit, type }` — the Firestore storage format.
  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(Self.distanceKind, forKey: .kind)
    try container.encode(category.value, forKey: .value)
    try container.encode(category.unit.rawValue, forKey: .unit)
    try container.encode(type.rawValue, forKey: .type)
  }
}
