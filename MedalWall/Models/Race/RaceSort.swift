//
//  RaceSort.swift
//  MedalWall
//
//  Created by Quien on 2026-03-20.
//

import Foundation

enum RaceSort: String, CaseIterable, Hashable {
  case name
  case country
  
  var displayName: String {
    switch self {
    case .name:    return "Name"
    case .country: return "Country"
    }
  }
  
  var comparator: (Race, Race) -> Bool {
    switch self {
    case .name:    return { $0.name.localizedCompare($1.name) == .orderedAscending }
    case .country: return { $0.location.country.localizedCompare($1.location.country) == .orderedAscending }
    }
  }
}
