//
//  RaceDistance.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation
import SwiftData

enum RaceDistance: String, Codable {
  case fullMarathon
  case halfMarathon
  case `10K`
  case `5K`
  
  var id: String { rawValue }
  
  var kilometers: Double {
    switch self {
    case .fullMarathon: return 42.195
    case .halfMarathon: return 21.0975
    case .`10K`: return 10
    case .`5K`: return 5
    }
  }
  
  var displayName: String {
    switch self {
    case .fullMarathon: return "Full Marathon"
    case .halfMarathon: return "Half Marathon"
    case .`10K`: return "10K"
    case .`5K`: return "5K"
    }
  }
}
