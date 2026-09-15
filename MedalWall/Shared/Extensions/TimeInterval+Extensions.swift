//
//  TimeInterval+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2026-09-15.
//

import Foundation

/// Formatting for durations — finish times, splits, pace.
///
/// `TimeInterval` is `Double`, so everything here is reachable on any `Double`, including
/// distances and progress fractions. Read the call site, not the type.
extension TimeInterval {
  /// Formats seconds as `HH:MM:SS` (e.g. `05:10:08`)
  var formattedHMS: String {
    Duration.seconds(self).formatted(.time(pattern: .hourMinuteSecond(padHourToLength: 2)))
  }
}
