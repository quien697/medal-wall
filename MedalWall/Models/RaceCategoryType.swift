//
//  RaceCategoryType.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

enum RaceCategoryType: String, Codable {
  case inPerson
  case virtual
  
  var id: String { rawValue }
  var displayName: String {
    switch self {
    case .inPerson: return "In-person"
    case .virtual: return "Virtual"
    }
  }
}
