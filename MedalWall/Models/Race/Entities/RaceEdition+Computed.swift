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
  
  var dateDisplayLabel: String {
    let startDate = startDate.formatted(.dateTime.month().day())
    let endDate = ", \(endDate.formatted(.dateTime.month().day()))"
    
    return "\(startDate)\(isOneDay ? "" : endDate)"
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
}
