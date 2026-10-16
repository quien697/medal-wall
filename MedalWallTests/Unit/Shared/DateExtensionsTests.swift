//
//  DateExtensionsTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-15.
//

import Foundation
import Testing

@testable import MedalWall

struct DateExtensionsTests {
  private let calendar = Calendar.current

  // MARK: - year
  @Test("year reads the calendar year of the date")
  func testYearReadsCalendarYear() throws {
    let date = try #require(calendar.date(from: DateComponents(year: 2025, month: 6, day: 15)))

    #expect(date.year == 2025)
  }

  // MARK: - startOfYear
  @Test("startOfYear is 1 January at midnight")
  func testStartOfYearIsFirstInstant() throws {
    let expected = try #require(calendar.date(from: DateComponents(year: 2025, month: 1, day: 1)))

    #expect(Date.startOfYear(2025) == expected)
  }

  // MARK: - endOfYear
  @Test("endOfYear falls on 31 December, not 1 January")
  func testEndOfYearFallsOnNewYearsEve() {
    let endOfYear = Date.endOfYear(2025)

    #expect(endOfYear.year == 2025)
    #expect(calendar.component(.month, from: endOfYear) == 12)
    #expect(calendar.component(.day, from: endOfYear) == 31)
  }

  @Test("endOfYear is after a time late on 31 December")
  func testEndOfYearIsAfterLateNewYearsEve() throws {
    let lateNewYearsEve = try #require(
      calendar.date(from: DateComponents(year: 2025, month: 12, day: 31, hour: 23, minute: 30))
    )

    #expect(Date.endOfYear(2025) > lateNewYearsEve)
  }

  @Test("endOfYear is before the following 1 January")
  func testEndOfYearIsBeforeNextYear() {
    #expect(Date.endOfYear(2025) < Date.startOfYear(2026))
  }

  // MARK: - yearRange
  @Test("yearRange contains a date late on 31 December")
  func testYearRangeContainsLateNewYearsEve() throws {
    let lateNewYearsEve = try #require(
      calendar.date(from: DateComponents(year: 2025, month: 12, day: 31, hour: 14))
    )

    #expect(Date.yearRange(2025).contains(lateNewYearsEve))
  }

  @Test("yearRange excludes the following 1 January")
  func testYearRangeExcludesNextYear() {
    #expect(Date.yearRange(2025).contains(Date.startOfYear(2026)) == false)
  }

  @Test("yearRange spans a leap day")
  func testYearRangeSpansLeapDay() throws {
    let leapDay = try #require(calendar.date(from: DateComponents(year: 2024, month: 2, day: 29)))

    #expect(Date.yearRange(2024).contains(leapDay))
  }
}
