//
//  RaceDistanceFactory.swift
//  MedalWall
//
//  Created by Quien on 2025-11-20.
//

import Foundation
import SwiftUI

final class RaceDistanceFactory {
  var distances: [RaceDistance]
  
  init() {
    self.distances = [
      RaceDistance(category: .full, type: .inPerson),   // 42.195
      RaceDistance(category: .half, type: .inPerson),   // 21.0975
      RaceDistance(category: .`10K`, type: .inPerson),  // 10
    ]
  }
  
  func addDistance(_ distance: RaceDistance) throws {
    if distances.contains(distance) {
      throw RaceEditError.duplicateDistance
    } else {
      distances.append(distance)
    }
  }
  
  func updateDistance(old: RaceDistance, with new: RaceDistance) throws {
    if distances.contains(new) {
      throw RaceEditError.duplicateDistance
    }
    if let index = distances.firstIndex(of: old) {
      distances[index] = new
    }
  }
  
  func deleteDistance(at offsets: IndexSet) {
    distances.remove(atOffsets: offsets)
  }
}
