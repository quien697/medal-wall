//
//  Item.swift
//  MedalWall
//
//  Created by Quien on 2025-10-20.
//

import Foundation
import SwiftData

@Model
final class Item {
  var timestamp: Date
  
  init(timestamp: Date) {
    self.timestamp = timestamp
  }
}
