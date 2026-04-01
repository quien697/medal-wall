//
//  EventPhotos+Computed.swift
//  MedalWall
//
//  Created by Quien on 2026-04-01.
//

import UIKit

/// Extends User with computed values
extension EventPhotos {
  
  var image: UIImage? {
    UIImage(data: imageData)
  }
}
