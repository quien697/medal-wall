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
  
  nonisolated
  var color: Color {
    switch self {
    case .fun: return .teal
    case .mini: return .blue
    case .half: return .green
    case .long: return .yellow
    case .full: return .orange
    case .ultra: return .red
    }
  }
  
  var translucentColor: Color {
    color.opacity(0.2)
  }
}
