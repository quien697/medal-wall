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
    guard let finishTime = result?.value, finishTime > 0, finishTime < Self.finishTimeLimit else {
      return nil
    }
    return finishTime
  }

  private static let finishTimeLimit: TimeInterval = 1_000 * 60 * 60

  /// Average pace in minutes per `unit`, or `nil` when there is no usable one.
  ///
  /// The distance is used as stored when it is already in `unit`, and converted only when it
  /// is not. Working out a mile distance's pace per kilometre and converting it back can land
  /// just under the true figure, and because pace truncates its seconds, 7'00" would read as
  /// 6'59".
  ///
  /// A pace of 1,000 minutes per unit or slower is not one anyone ran; it comes from a
  /// distance stored near zero, and showing it through `Int(_:)` would crash the app. An
  /// infinite distance would give a pace of zero. Both read as no pace.
  func averagePace(in unit: DistanceUnit) -> Double? {
    var distance = event.category.value
    if event.category.unit != unit {
      distance =
        unit == .miles
        ? distance / DistanceUnit.kilometersPerMile : distance * DistanceUnit.kilometersPerMile
    }
    guard let recordedFinishTime, distance > 0, distance.isFinite else { return nil }
    let pace = (recordedFinishTime / 60) / distance
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
