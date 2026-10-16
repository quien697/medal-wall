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

  /// Average pace in minutes per kilometre, or `nil` when there is no usable one.
  ///
  /// A pace of 1,000 minutes per kilometre or slower is not one anyone ran; it comes from a
  /// distance stored near zero, and showing it through `Int(_:)` would crash the app. An
  /// infinite distance would give a pace of zero. Both read as no pace.
  var averagePace: Double? {
    guard let recordedFinishTime, distance.category.value > 0, distance.category.value.isFinite
    else { return nil }
    let pace = (recordedFinishTime / 60) / distance.category.value
    return pace < Self.paceLimit ? pace : nil
  }

  private static let paceLimit = 1_000.0

  /// The stored `division` string as a `Division`, or `nil` when absent or unrecognised.
  ///
  /// `division` stays a string on purpose: an unrecognised value then hides the division
  /// instead of failing the whole medal's decode.
  var parsedDivision: Division? {
    guard let division else { return nil }
    return Division(rawValue: division)
  }
}
