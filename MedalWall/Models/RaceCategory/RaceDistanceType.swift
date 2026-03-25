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
  case wheelChair
  
  var id: String { rawValue }
  
  /// Defines display name for UI
  var displayName: String {
    switch self {
    case .inPerson: return "In-person"
    case .virtual: return "Virtual"
    case .wheelChair: return "Wheel Chair"
    }
  }
  
  /// Defines the sort order for UI
  var sortOrder: Int {
    switch self {
    case .inPerson: return 0
    case .virtual: return 1
    case .wheelChair: return 2
    }
  }
}
