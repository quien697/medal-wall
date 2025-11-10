//
//  RaceDistance.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation

/// Represents a specific marathon distance combined with its details
struct RaceDistance: Identifiable, Hashable {
  let id: UUID = UUID()
  var category: RaceDistanceCategory
  var type: RaceDistanceType
  
  static let `default` = RaceDistance(
    category: .full,
    type: .inPerson
  )
}

/// Defines the participation format for a race
enum RaceDistanceType: String, Hashable {
  case inPerson
  case virtual
  
  var id: String { rawValue }
  
  nonisolated
  var displayName: String {
    switch self {
    case .inPerson: return "In-person"
    case .virtual: return "Virtual"
    }
  }
}
