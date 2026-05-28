//
//  HMSDuration.swift
//  MedalWall
//
//  Created by Quien on 2026-01-04.
//

import Foundation

struct HMSDuration: Equatable {
  var hours: Int
  var minutes: Int
  var seconds: Int

  init(hours: Int = 0, minutes: Int = 0, seconds: Int = 0) {
    self.hours = max(0, hours)
    self.minutes = min(max(0, minutes), 59)
    self.seconds = min(max(0, seconds), 59)
  }

  init(_ timeInterval: TimeInterval?) {
    if let timeInterval {
      let total = Int(timeInterval)
      self.hours = total / 3600
      self.minutes = (total % 3600) / 60
      self.seconds = total % 60
    } else {
      self.hours = 0
      self.minutes = 0
      self.seconds = 0
    }
  }

  var timeInterval: TimeInterval {
    TimeInterval(hours * 3600 + minutes * 60 + seconds)
  }

  var isEmpty: Bool {
    return hours == 0 && minutes == 0 && seconds == 0
  }

  /// Always renders digits — used inside the wheel picker (e.g. `00 : 00 : 00`)
  var formattedString: String {
    String(format: "%02d : %02d : %02d", hours, minutes, seconds)
  }

  /// Renders a placeholder when empty — used in the button label (e.g. `-- : -- : --`)
  var displayString: String {
    isEmpty ? "-- : -- : --" : formattedString
  }

  /// Parse value from String to DurationHMS
  static func parse(_ string: String) -> HMSDuration? {
    let parts = string.split(separator: ":")
    guard
      parts.count == 3,
      let hours = Int(parts[0]),
      let minutes = Int(parts[1]),
      let seconds = Int(parts[2]),
      (0...59).contains(minutes),
      (0...59).contains(seconds),
      hours >= 0
    else {
      return nil
    }

    return HMSDuration(hours: hours, minutes: minutes, seconds: seconds)
  }
}
