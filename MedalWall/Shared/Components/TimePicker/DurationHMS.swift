//
//  DurationHMS.swift
//  MedalWall
//
//  Created by Quien on 2026-01-04.
//

import Foundation

struct DurationHMS: Equatable {
  var hours: Int
  var minutes: Int
  var seconds: Int
  
  init(hours: Int = 0, minutes: Int = 0, seconds: Int = 0) {
    self.hours = max(0, hours)
    self.minutes = min(max(0, minutes), 59)
    self.seconds = min(max(0, seconds), 59)
  }
  
  init(timeInterval: TimeInterval) {
    let total = Int(timeInterval)
    self.hours = total / 3600
    self.minutes = (total % 3600) / 60
    self.seconds = total % 60
  }
  
  var timeInterval: TimeInterval {
    TimeInterval(hours * 3600 + minutes * 60 + seconds)
  }
  
  var isEmpty: Bool {
    return hours == 0 && minutes == 0 && seconds == 0
  }
  
  /// Formate value from DurationHMS to String
  var stringValue: String {
    if isEmpty {
      return "-- : -- : --"
    } else {
      return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
  }
  
  /// Parse value from String to DurationHMS
  static func parse(_ string: String) -> DurationHMS? {
    let parts = string.split(separator: ":")
    guard
      parts.count == 3,
      let h = Int(parts[0]),
      let m = Int(parts[1]),
      let s = Int(parts[2]),
      (0...59).contains(m),
      (0...59).contains(s),
      h >= 0 else {
      return nil
    }
    
    return DurationHMS(hours: h, minutes: m, seconds: s)
  }
}
