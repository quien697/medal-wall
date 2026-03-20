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
  
  var order: [SortDescriptor<Race>] {
    switch self {
    case .name:    return [SortDescriptor(\.name)]
    case .country: return [SortDescriptor(\.country)]
    }
  }
}
