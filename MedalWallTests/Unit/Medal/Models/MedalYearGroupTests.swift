//
//  MedalYearGroupTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-07.
//

import Foundation
import Testing

@testable import MedalWall

struct MedalYearGroupTests {

  private func makeMedal(date: Date = .now) -> Medal {
    Medal(
      name: "Test",
      date: date,
      bibNumber: "1",
      place: Place(countryCode: "CA", city: "Vancouver"),
      distance: RaceDistance(category: .full, type: .inPerson),
      userID: "user1"
    )
  }

  // MARK: - Identifiable
  @Test("id is the year")
  func testIDIsTheYear() {
    let group = MedalYearGroup(year: 2025, medals: [makeMedal()])

    #expect(group.id == 2025)
  }

  @Test("Two groups for the same year carry the same id")
  func testSameYearSharesID() {
    let first = MedalYearGroup(year: 2022, medals: [makeMedal()])
    let second = MedalYearGroup(year: 2022, medals: [])

    #expect(first.id == second.id)
  }

  @Test("Two groups for different years carry distinct ids")
  func testDifferentYearsHaveDistinctIDs() {
    let first = MedalYearGroup(year: 2025, medals: [])
    let second = MedalYearGroup(year: 2019, medals: [])

    #expect(first.id != second.id)
  }

  // MARK: - Contents
  @Test("A group holds the medals it was built with")
  func testGroupHoldsItsMedals() {
    let medals = [makeMedal(), makeMedal()]
    let group = MedalYearGroup(year: 2025, medals: medals)

    #expect(group.medals.count == 2)
  }
}
