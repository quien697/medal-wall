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
      RaceDistance(category: .`10K`, type: .inPerson),  // 10
      RaceDistance(category: .`5K`, type: .inPerson),   // 5
      RaceDistance(category: .full, type: .virtual),    // 42.195
      RaceDistance(category: .half, type: .virtual),    // 21.0975
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
  
  func deleteDistance(_ distance: RaceDistance) {
    if let index = distances.firstIndex(of: distance) {
      distances.remove(at: index)
    }
  }
}
