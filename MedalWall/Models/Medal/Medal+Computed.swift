//
//  Medal+Computed.swift
//  MedalWall
//
//  Created by Quien on 2026-04-01.
//

import Foundation

extension Medal {
  /// The finish time actually run, or `nil` when nothing usable was recorded.
  ///
  /// A stored zero or negative is not a real time — it would otherwise format as
  /// "00:00:00" and compute a pace of `0'00"`, rather than reading as unrecorded.
  var recordedFinishTime: TimeInterval? {
    guard let finishTime, finishTime > 0 else { return nil }
    return finishTime
  }

  /// Average pace in minutes per kilometre
  var averagePace: Double? {
    guard let recordedFinishTime, distance.category.value > 0 else { return nil }
    return (recordedFinishTime / 60) / distance.category.value
  }

  var divisionEnum: Division? {
    guard let division else { return nil }
    return Division(rawValue: division)
  }
}
