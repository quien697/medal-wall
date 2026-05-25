//
//  EventPhotos+Computed.swift
//  MedalWall
//
//  Created by Quien on 2026-04-01.
//

import UIKit

/// Extends EventPhoto with computed values
extension EventPhoto {

  var image: UIImage? {
    UIImage(data: imageData)
  }
}
