//
//  Date+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2026-03-18.
//

import Foundation

extension Date {
  
  func formattedMonthDay() -> String {
    formatted(.dateTime.month().day())
  }
  
  func formattedMonthDayYear() -> String {
    formatted(.dateTime.month().day().year())
  }
}

extension TimeInterval {
  /// Formats seconds as `HH:MM:SS` (e.g. `05:10:08`)
  var formattedHMS: String {
    Duration.seconds(self).formatted(.time(pattern: .hourMinuteSecond(padHourToLength: 2)))
  }
}
