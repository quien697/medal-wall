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
    case .name: return "Name"
    case .country: return "Country"
    }
  }
  
  var order: [SortDescriptor<Race>] {
    switch self {
    case .name:    return [SortDescriptor(\.name)]
    case .country: return [SortDescriptor(\.country)]
    }
  }
}
