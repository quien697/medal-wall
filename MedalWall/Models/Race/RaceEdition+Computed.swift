//
//  RaceEdition+Computed.swift
//  MedalWall
//
//  Created by Quien on 2026-03-16.
//

import UIKit

/// Extends RaceEdition with computed values
extension RaceEdition {
  
  var photo: UIImage? {
    if let photoData {
      return UIImage(data: photoData)
    }
    
    return nil
  }
  
  var cropPhoto: UIImage? {
    if let cropPhotoData {
      return UIImage(data: cropPhotoData)
    }
    
    return nil
  }
  
  var isOneDay: Bool {
      Calendar.current.isDate(startDate, inSameDayAs: endDate)
  }
  
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
