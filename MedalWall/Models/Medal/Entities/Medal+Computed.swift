//
//  Medal+Computed.swift
//  MedalWall
//
//  Created by Quien on 2026-04-01.
//

import UIKit

/// Extends Medal with computed values
extension Medal {

  var photo: UIImage? {
    photoData.flatMap { UIImage(data: $0) }
  }

  var location: GeoLocation {
    GeoLocation(country: country, province: province, city: city, district: district)
  }

  var distance: RaceDistance {
    RaceDistance(
      category: RaceDistanceCategory(value: raceDistance),
      type: RaceDistanceType(rawValue: raceDistanceType) ?? .inPerson
    )
  }

  // MARK: - Result

  /// Average pace in minutes per kilometre
  var averagePace: Double? {
    guard let finishTime, raceDistance > 0 else { return nil }

    return (finishTime / 60) / raceDistance
  }

  var divisionEnum: Division? {
    guard let division else { return nil }
    return Division(rawValue: division)
  }
}
