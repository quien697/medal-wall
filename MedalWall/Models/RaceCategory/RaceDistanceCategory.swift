//
//  RaceDistanceCategory.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
//

import SwiftUI

/// Represents standard or custom marathon distance categories,
/// used to display each distance with a distinct color.
enum RaceDistanceCategory: CustomStringConvertible, Hashable {
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
      if value.truncatingRemainder(dividingBy: 1) == 0 {
        return "\(Int(value))K"
      } else {
        return "\(value)K"
      }
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
  
  var group: RaceDistanceCategoryGroup {
    switch value {
    case ..<5: return .fun
    case 5..<15: return .mini
    case 15..<25: return .half
    case 25..<40: return .long
    case 40..<45: return .full
    default: return .ultra
    }
  }
  
  var color: Color {
    group.color
  }
  
  var translucentColor: Color {
    group.translucentColor
  }
}

/// Initializes a distance category from a numeric distance value (in kilometers)..
extension RaceDistanceCategory {
  nonisolated
  init(value: Double) {
    switch value {
    case 42.195: self = .full
    case 21.0975: self = .half
    case 10: self = .`10K`
    case 5: self = .`5K`
    default: self = .custom(value)
    }
  }
  
  static var standardCases: [RaceDistanceCategory] {
    [.full, .half, .`10K`, .`5K`]
  }
}
