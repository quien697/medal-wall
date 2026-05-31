//
//  RaceEditionTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Foundation
import Testing

@testable import MedalWall

struct RaceEditionTests {
  private let raceId = "race-1"
  private let createdBy = "user-1"

  private func makeEdition(startDate: Date, endDate: Date) -> RaceEdition {
    RaceEdition(
      raceId: raceId,
      year: 2025,
      startDate: startDate,
      endDate: endDate,
      createdBy: createdBy
    )
  }

  // MARK: - isOneDay
  @Test("isOneDay is true when start and end are the same midnight date")
  func testIsOneDayTrue() {
    let day = Calendar.current.startOfDay(for: Date(timeIntervalSinceReferenceDate: 0))
    let edition = makeEdition(startDate: day, endDate: day)

    #expect(edition.isOneDay == true)
  }

  @Test("isOneDay is false when start and end are midnight dates on different days")
  func testIsOneDayFalse() {
    let start = Calendar.current.startOfDay(for: Date(timeIntervalSinceReferenceDate: 0))
    let end = Calendar.current.startOfDay(for: start.addingTimeInterval(86400))
    let edition = makeEdition(startDate: start, endDate: end)

    #expect(edition.isOneDay == false)
  }

  // MARK: - dateDisplayLabel
  @Test("dateDisplayLabel shows only start date for a one-day event")
  func testDateDisplayLabelOneDay() {
    let day = Date(timeIntervalSinceReferenceDate: 0)
    let edition = makeEdition(startDate: day, endDate: day)

    let expected = day.formattedMonthDay()
    #expect(edition.dateDisplayLabel == expected)
  }

  @Test("dateDisplayLabel shows both dates separated by comma for a multi-day event")
  func testDateDisplayLabelMultiDay() {
    let start = Date(timeIntervalSinceReferenceDate: 0)
    let end = start.addingTimeInterval(86400)
    let edition = makeEdition(startDate: start, endDate: end)

    let expected = "\(start.formattedMonthDay()), \(end.formattedMonthDay())"
    #expect(edition.dateDisplayLabel == expected)
  }
}
