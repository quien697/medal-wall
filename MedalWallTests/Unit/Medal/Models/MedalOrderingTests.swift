//
//  MedalOrderingTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-07.
//

import Foundation
import Testing

@testable import MedalWall

struct MedalOrderingTests {

  private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = 12
    return Calendar.current.date(from: components) ?? .now
  }

  private func makeMedal(id: String, date: Date) -> Medal {
    Medal(
      id: id,
      name: "Test",
      date: date,
      bibNumber: "1",
      place: Place(countryCode: "CA", city: "Vancouver"),
      distance: RaceDistance(category: .full, type: .inPerson),
      userID: "user1"
    )
  }

  // MARK: - sortedForDisplay
  @Test("sortedForDisplay is empty for an empty array")
  func testSortedForDisplayEmpty() {
    let medals: [Medal] = []

    #expect(medals.sortedForDisplay.isEmpty)
  }

  @Test("sortedForDisplay puts the most recent medal first")
  func testSortedForDisplayMostRecentFirst() {
    let medals = [
      makeMedal(id: "old", date: makeDate(2019, 12, 15)),
      makeMedal(id: "new", date: makeDate(2025, 12, 20)),
      makeMedal(id: "mid", date: makeDate(2022, 5, 1))
    ]

    #expect(medals.sortedForDisplay.map(\.id) == ["new", "mid", "old"])
  }

  @Test("sortedForDisplay breaks a shared date by id so the order is stable")
  func testSortedForDisplayTieBrokenByID() {
    let sharedDate = makeDate(2022, 5, 1)
    let medals = [
      makeMedal(id: "b", date: sharedDate),
      makeMedal(id: "a", date: sharedDate)
    ]

    #expect(medals.sortedForDisplay.map(\.id) == ["a", "b"])
  }

  @Test("sortedForDisplay does not depend on the input order")
  func testSortedForDisplayIgnoresInputOrder() {
    let first = makeMedal(id: "first", date: makeDate(2025, 1, 1))
    let second = makeMedal(id: "second", date: makeDate(2022, 1, 1))
    let third = makeMedal(id: "third", date: makeDate(2019, 1, 1))

    let oneOrder = [first, second, third].sortedForDisplay.map(\.id)
    let anotherOrder = [third, first, second].sortedForDisplay.map(\.id)

    #expect(oneOrder == anotherOrder)
  }

  // MARK: - groupedByYear
  @Test("groupedByYear produces no groups for an empty array")
  func testGroupedByYearEmpty() {
    let medals: [Medal] = []

    #expect(medals.groupedByYear.isEmpty)
  }

  @Test("groupedByYear produces one group of one for a single medal")
  func testGroupedByYearSingleMedal() {
    let medals = [makeMedal(id: "a", date: makeDate(2025, 12, 20))]

    let groups = medals.groupedByYear

    #expect(groups.count == 1)
    #expect(groups.first?.year == 2025)
    #expect(groups.first?.medals.count == 1)
  }

  @Test("groupedByYear orders years most recent first")
  func testGroupedByYearOrdersYearsDescending() {
    let medals = [
      makeMedal(id: "a", date: makeDate(2019, 12, 15)),
      makeMedal(id: "b", date: makeDate(2025, 12, 20)),
      makeMedal(id: "c", date: makeDate(2022, 5, 1))
    ]

    #expect(medals.groupedByYear.map(\.year) == [2025, 2022, 2019])
  }

  @Test("groupedByYear collects every medal earned in the same year")
  func testGroupedByYearCollectsSameYear() {
    let medals = [
      makeMedal(id: "a", date: makeDate(2022, 5, 1)),
      makeMedal(id: "b", date: makeDate(2022, 12, 18)),
      makeMedal(id: "c", date: makeDate(2025, 12, 20))
    ]

    let groups = medals.groupedByYear

    #expect(groups.map(\.year) == [2025, 2022])
    #expect(groups.last?.medals.count == 2)
  }

  @Test("groupedByYear orders medals inside a group most recent first")
  func testGroupedByYearOrdersWithinGroup() {
    let medals = [
      makeMedal(id: "may", date: makeDate(2022, 5, 1)),
      makeMedal(id: "december", date: makeDate(2022, 12, 18))
    ]

    #expect(medals.groupedByYear.first?.medals.map(\.id) == ["december", "may"])
  }

  @Test("groupedByYear omits years with no medals")
  func testGroupedByYearOmitsGapYears() {
    let medals = [
      makeMedal(id: "a", date: makeDate(2025, 12, 20)),
      makeMedal(id: "b", date: makeDate(2019, 12, 15))
    ]

    #expect(medals.groupedByYear.map(\.year) == [2025, 2019])
  }

  @Test("groupedByYear separates medals that sit either side of a year boundary")
  func testGroupedByYearSeparatesAcrossBoundary() {
    let medals = [
      makeMedal(id: "newYearsEve", date: makeDate(2022, 12, 31)),
      makeMedal(id: "newYearsDay", date: makeDate(2023, 1, 1))
    ]

    let groups = medals.groupedByYear

    #expect(groups.map(\.year) == [2023, 2022])
    #expect(groups.allSatisfy { $0.medals.count == 1 })
  }
}
