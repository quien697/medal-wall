//
//  Medal+Computed.swift
//  MedalWall
//
//  Created by Quien on 2026-04-01.
//

import UIKit

extension Medal {

  // MARK: - Media
  
  var photo: UIImage? {
    photoData.flatMap { UIImage(data: $0) }
  }

  var cropPhoto: UIImage? {
    cropPhotoData.flatMap { UIImage(data: $0) }
  }
  
  // MARK: - Location
  
  var location: RaceLocation {
    RaceLocation(country: country, province: province, city: city, district: district)
  }

  // MARK: - Race category
  
  var raceDistanceCategory: RaceDistanceCategory {
    RaceDistanceCategory(value: raceDistance)
  }

  var raceDistanceType: RaceDistanceType {
    RaceDistanceType(rawValue: raceType) ?? .inPerson
  }

  // MARK: - Result
  
//  var divisionEnum: Division? {
//    guard let division else { return nil }
//    return Division(rawValue: division)
//  }

  /// Average pace in minutes per kilometre
  var avgPace: Double? {
    guard let finishTime, raceDistance > 0 else { return nil }
    
    return (finishTime / 60) / raceDistance
  }
}
