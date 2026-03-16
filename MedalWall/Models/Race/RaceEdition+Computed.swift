//
//  RaceEdition+Computed.swift
//  MedalWall
//
//  Created by Quien on 2026-03-16.
//

/// Extends RaceEdition with computed values
extension RaceEdition {
  
  /// Converts categories to [RaceDistance]
  var distances: [RaceDistance] {
    categories.map {
      RaceDistance(
        category: RaceDistanceCategory(value: $0.distance),
        type: RaceDistanceType(rawValue: $0.type) ?? .inPerson
      )
    }
  }
  
  /// Groups distances by type
  var distancesGroupedByType: [RaceDistanceType: [RaceDistance]] {
    distances.groupedByType()
  }
  
  /// Returns distances grouped by type in order
  var distancesByTypeOrdered: [(type: RaceDistanceType, distances: [RaceDistance])] {
    let grouped = distancesGroupedByType
    
    return RaceDistanceType.allCases.compactMap { type in
      guard let distances = grouped[type], !distances.isEmpty else { return nil }
      
      return (type, distances)
    }
  }
}
