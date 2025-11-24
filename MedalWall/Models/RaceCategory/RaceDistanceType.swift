//
//  RaceDistanceType.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

/// Defines the participation format for a race
enum RaceDistanceType: String, Hashable, CaseIterable, Identifiable {
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
