//
//  MedalComputedTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-29.
//

import Foundation
import Testing

@testable import MedalWall

struct MedalComputedTests {

  private func makeMedal(
    distance: RaceDistance = RaceDistance(category: .full, type: .inPerson),
    finishTime: TimeInterval? = nil,
    division: Division? = nil
  ) -> Medal {
    Medal(
      name: "Test",
      date: .now,
      bibNumber: "1",
      location: GeoLocation(country: "Canada", city: "Vancouver"),
      distance: distance, finishTime: finishTime,
      division: division, userID: "user1"
    )
  }

  // MARK: - averagePace
  @Test("averagePace is nil when finishTime is nil")
  func testAveragePaceNilWhenNoFinishTime() {
    let medal = makeMedal()

    #expect(medal.averagePace == nil)
  }

  @Test("averagePace is nil when custom distance is zero")
  func testAveragePaceNilWhenCustomDistanceZero() {
    let medal = makeMedal(
      distance: RaceDistance(category: .custom(0), type: .inPerson),
      finishTime: 3600
    )

    #expect(medal.averagePace == nil)
  }

  @Test("averagePace is nil when custom distance is negative")
  func testAveragePaceNilWhenCustomDistanceNegative() {
    let medal = makeMedal(
      distance: RaceDistance(category: .custom(-5), type: .inPerson),
      finishTime: 3600
    )

    #expect(medal.averagePace == nil)
  }

  @Test("averagePace calculates minutes per km for a full marathon")
  func testAveragePaceCalculation() {
    let finishTime: TimeInterval = 12624
    let medal = makeMedal(finishTime: finishTime)

    let expected = (finishTime / 60) / RaceDistanceCategory.full.value
    #expect(medal.averagePace == expected)
  }

  // MARK: - divisionEnum
  @Test("divisionEnum is nil when division is nil")
  func testDivisionEnumNilWhenNoDivision() {
    let medal = makeMedal()

    #expect(medal.divisionEnum == nil)
  }

  @Test("divisionEnum reconstructs a valid Division from its stored raw value")
  func testDivisionEnumValid() {
    let division = Division(gender: .male, ageGroup: .from30to34)
    let medal = makeMedal(division: division)

    #expect(medal.divisionEnum?.gender == .male)
    #expect(medal.divisionEnum?.ageGroup == .from30to34)
  }

  @Test("divisionEnum round-trips through Medal storage for a female division")
  func testDivisionEnumRoundTripFemale() {
    let division = Division(gender: .female, ageGroup: .from40to44)
    let medal = makeMedal(division: division)

    #expect(medal.divisionEnum == division)
  }
}
