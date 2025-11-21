//
//  RaceFilter.swift
//  MedalWall
//
//  Created by Quien on 2025-11-21.
//

import Foundation

struct RaceFilter {
  var selectedTypes: Set<RaceDistanceType> = []
  var selectedCategories: Set<RaceDistanceCategory> = []
  var searchQuery: String = ""
  
  var isEmpty: Bool {
    selectedTypes.isEmpty &&
    selectedCategories.isEmpty &&
    searchQuery.trimmingCharacters(in: .whitespaces).isEmpty
  }
  
  static let `default` = RaceFilter()
}
