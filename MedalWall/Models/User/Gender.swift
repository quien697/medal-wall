//
//  Gender.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation

enum Gender: String, CaseIterable, Codable {
  case male
  case female

  var displayName: String {
    switch self {
    case .male: return .appLocalized("Male")
    case .female: return .appLocalized("Female")
    }
  }

  var shortName: String {
    switch self {
    case .male: return .appLocalized("M")
    case .female: return .appLocalized("F")
    }
  }
}
