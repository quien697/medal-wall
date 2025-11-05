//
//  RaceType.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
//

/// Represents the type of race event
enum RaceType: String {
  case road
  case trail
  case obstacle
  
  var id: String { rawValue }
  
  var displayName: String {
    switch self {
    case .road: return "Road"
    case .trail: return "trail"
    case .obstacle: return "Obstacle"
    }
  }
}
