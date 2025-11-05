//
//  MeasurementUnit.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

enum MeasurementUnit: String, Codable {
  case km
  case mi
  
  var id: String { rawValue }
  
  nonisolated
  var displayName: String {
    switch self {
    case .km: return "km"
    case .mi: return "mi"
    }
  }
}
