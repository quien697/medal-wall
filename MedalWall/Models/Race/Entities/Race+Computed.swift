//
//  Race+Computed.swift
//  MedalWall
//
//  Created by Quien on 2026-03-09.
//

import UIKit

/// Extends Race with computed values
extension Race {
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
  
  var location: RaceLocation {
    RaceLocation(
      country: country,
      province: province,
      city: city,
      district: district
    )
  }
}
