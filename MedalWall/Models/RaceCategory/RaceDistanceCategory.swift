//
//  RaceDistanceCategory.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
//

import SwiftUI

/// Represents standard or custom marathon distance categories,
/// used to display each distance with a distinct color.
enum RaceDistanceCategory: CustomStringConvertible {
  case full
  case half
  case `10K`
  case `5K`
  case custom(Double)
  
  nonisolated
  var description: String {
    switch self {
    case .full: return "42K"
    case .half: return "21K"
    case .`10K`: return "10K"
    case .`5K`: return "5K"
    case .custom(let value):
      return "\(value)K"
    }
  }
  
  nonisolated
  var value: Double {
    switch self {
    case .full: return 42.195
    case .half: return 21.0975
    case .`10K`: return 10
    case .`5K`: return 5
    case .custom(let value): return value
    }
  }
}
