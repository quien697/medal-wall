//
//  RaceDistance.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

/// Represents a specific marathon distance combined with its details
struct RaceDistance {
  let Category: RaceDistanceCategory
  let type: RaceDistanceType
}

/// Defines the participation format for a race
enum RaceDistanceType: String {
  case inPerson
  case virtual
  
  var id: String { rawValue }
  
  var displayName: String {
    switch self {
    case .inPerson: return "In-person"
    case .virtual: return "Virtual"
    }
  }
}

