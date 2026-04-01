//
//  Gender.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

enum Gender: String, CaseIterable {
  case male
  case female
  
  var id: String { rawValue }
  
  nonisolated
  var displayName: String {
    switch self {
    case .male: return "Male"
    case .female: return "Female"
    }
  }
}
