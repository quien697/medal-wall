//
//  RaceDistanceCategoryGroup.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
//

import SwiftUI

/// Represents the group of marathon distances into tiers
enum RaceDistanceCategoryGroup: String, CaseIterable {
  case fun = "Fun"        // < 5K
  case mini = "Mini"      // 5 - 15K
  case half = "Half"      // 15K - 21K
  case long = "Long"      // 21K - 42K
  case full = "Full"      // 42K
  case ultra = "Ultra"    // > 42K
  
  var id: String { rawValue }
  
  var color: Color {
    switch self {
    case .fun: return .teal.opacity(0.2)
    case .mini: return .blue.opacity(0.2)
    case .half: return .green.opacity(0.2)
    case .long: return .yellow.opacity(0.2)
    case .full: return .orange.opacity(0.2)
    case .ultra: return .red.opacity(0.2)
    }
  }
}
