//
//  Medal+Computed.swift
//  MedalWall
//
//  Created by Quien on 2026-04-01.
//

extension Medal {
  /// Average pace in minutes per kilometre
  var averagePace: Double? {
    guard let finishTime, distance.category.value > 0 else { return nil }
    return (finishTime / 60) / distance.category.value
  }

  var divisionEnum: Division? {
    guard let division else { return nil }
    return Division(rawValue: division)
  }
}
