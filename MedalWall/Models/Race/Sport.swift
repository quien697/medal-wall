//
//  Sport.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
//

/// Represents the type of sport for a race event
enum Sport: String {
  case running
  
  var id: String { rawValue }
  
  var displayName: String {
    switch self {
    case .running: return "Running"
    }
  }
}
