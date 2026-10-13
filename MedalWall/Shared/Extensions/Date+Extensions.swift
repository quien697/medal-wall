//
//  Date+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2026-03-18.
//

import Foundation

/// Year arithmetic and display formatting for dates.
///
/// Anything that reaches for a `Calendar` or `DateComponents` to answer a question about a
/// year belongs here rather than in a ViewModel, so the boundaries of a year are defined once.
extension Date {

  // MARK: - Year
  /// Years are Gregorian whatever calendar the device uses: an edition's year is stored and
  /// shared with other clients, and a device set to the ROC, Japanese or Buddhist calendar
  /// would otherwise read 2026 as 115, 8 or 2569. Days still start in the device's time zone.
  private static let yearCalendar = Calendar(identifier: .gregorian)

  /// The Gregorian year this date falls in.
  var year: Int {
    Self.yearCalendar.component(.year, from: self)
  }

  /// The first instant of the Gregorian `year` — 1 January at 00:00.
  static func startOfYear(_ year: Int) -> Date {
    yearCalendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? .now
  }

  /// The last instant of `year` — 31 December at 23:59:59.
  ///
  /// Deliberately the *end* of 31 December rather than its start: a race held that day at
  /// any time still falls inside the year, so a date picker bounded by this can reach it.
  static func endOfYear(_ year: Int) -> Date {
    startOfYear(year + 1).addingTimeInterval(-1)
  }

  /// The full span of `year`, for date picker bounds and range clamping.
  static func yearRange(_ year: Int) -> ClosedRange<Date> {
    startOfYear(year)...endOfYear(year)
  }

  // MARK: - Formatting
  /// The month and day in the user's locale (e.g. `Dec 15`), for dates whose year is
  /// already established by their surroundings.
  func formattedMonthDay() -> String {
    formatted(.dateTime.month().day())
  }

  /// The month, day and year in the user's locale (e.g. `Dec 15, 2025`).
  func formattedMonthDayYear() -> String {
    formatted(.dateTime.month().day().year())
  }
}
