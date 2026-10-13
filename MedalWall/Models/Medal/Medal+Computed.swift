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
  /// "00:00:00" and compute a pace of `0'00"`, rather than reading as unrecorded. Nor is
  /// infinity or 1,000 hours or more, which another client or a corrupt document could
  /// store: `Duration` traps on such values, so formatting one would crash the app.
  var recordedFinishTime: TimeInterval? {
    guard let finishTime, finishTime > 0, finishTime < Self.finishTimeLimit else { return nil }
    return finishTime
  }

  private static let finishTimeLimit: TimeInterval = 1_000 * 60 * 60

  /// Average pace in minutes per kilometre
  var averagePace: Double? {
    guard let recordedFinishTime, distance.category.value > 0 else { return nil }
    return (recordedFinishTime / 60) / distance.category.value
  }

  /// The stored `division` string as a `Division`, or `nil` when absent or unrecognised.
  ///
  /// `division` stays a string on purpose: an unrecognised value then hides the division
  /// instead of failing the whole medal's decode.
  var parsedDivision: Division? {
    guard let division else { return nil }
    return Division(rawValue: division)
  }
}
