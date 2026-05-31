//
//  MedalStatsTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-29.
//

import Foundation
import Testing

@testable import MedalWall

struct MedalStatsTests {

  private func makeMedal(
    distance: RaceDistance = RaceDistance(category: .full, type: .inPerson),
    finishTime: TimeInterval? = nil
  ) -> Medal {
    Medal(
      name: "Test",
      date: .now,
      bibNumber: "1",
      location: GeoLocation(country: "Canada", city: "Vancouver"),
      distance: distance, finishTime: finishTime,
      userID: "user1"
    )
  }

  // MARK: - fullCount
  @Test("fullCount is zero for an empty array")
  func testFullCountZeroWhenEmpty() {
    let medals: [Medal] = []

    #expect(medals.fullCount == 0)
  }

  @Test("fullCount only counts full marathons")
  func testFullCountOnlyCountsFull() {
    let medals: [Medal] = [
      makeMedal(distance: RaceDistance(category: .full, type: .inPerson)),
      makeMedal(distance: RaceDistance(category: .full, type: .inPerson)),
      makeMedal(distance: RaceDistance(category: .half, type: .inPerson))
    ]

    #expect(medals.fullCount == 2)
  }

  // MARK: - halfCount
  @Test("halfCount is zero for an empty array")
  func testHalfCountZeroWhenEmpty() {
    let medals: [Medal] = []

    #expect(medals.halfCount == 0)
  }

  @Test("halfCount only counts half marathons")
  func testHalfCountOnlyCountsHalf() {
    let medals: [Medal] = [
      makeMedal(distance: RaceDistance(category: .full, type: .inPerson)),
      makeMedal(distance: RaceDistance(category: .half, type: .inPerson)),
      makeMedal(distance: RaceDistance(category: .half, type: .inPerson)),
      makeMedal(distance: RaceDistance(category: .half, type: .virtual))
    ]

    #expect(medals.halfCount == 3)
  }

  // MARK: - bestFullTime
  @Test("bestFullTime is nil when there are no full marathons")
  func testBestFullTimeNilWhenNoFulls() {
    let medals: [Medal] = [
      makeMedal(distance: RaceDistance(category: .half, type: .inPerson), finishTime: 7200)
    ]

    #expect(medals.bestFullTime == nil)
  }

  @Test("bestFullTime is nil when all full marathon medals have no finish time")
  func testBestFullTimeNilWhenNoFinishTimes() {
    let medals: [Medal] = [
      makeMedal(distance: RaceDistance(category: .full, type: .inPerson)),
      makeMedal(distance: RaceDistance(category: .full, type: .inPerson))
    ]

    #expect(medals.bestFullTime == nil)
  }

  @Test("bestFullTime ignores full marathon medals with no finish time")
  func testBestFullTimeMixedFinishTimes() {
    let medals: [Medal] = [
      makeMedal(distance: RaceDistance(category: .full, type: .inPerson), finishTime: 3600),
      makeMedal(distance: RaceDistance(category: .full, type: .inPerson), finishTime: nil)
    ]

    #expect(medals.bestFullTime == 3600)
  }

  @Test("bestFullTime returns the minimum finish time across full marathon medals")
  func testBestFullTimeReturnsMinimum() {
    let medals: [Medal] = [
      makeMedal(distance: RaceDistance(category: .full, type: .inPerson), finishTime: 3600),
      makeMedal(distance: RaceDistance(category: .full, type: .inPerson), finishTime: 7200),
      makeMedal(distance: RaceDistance(category: .full, type: .inPerson), finishTime: 5400)
    ]

    #expect(medals.bestFullTime == 3600)
  }

  // MARK: - bestHalfTime
  @Test("bestHalfTime is nil when there are no half marathons")
  func testBestHalfTimeNilWhenNoHalfs() {
    let medals: [Medal] = [
      makeMedal(distance: RaceDistance(category: .full, type: .inPerson), finishTime: 3600)
    ]

    #expect(medals.bestHalfTime == nil)
  }

  @Test("bestHalfTime is nil when all half marathon medals have no finish time")
  func testBestHalfTimeNilWhenNoFinishTimes() {
    let medals: [Medal] = [
      makeMedal(distance: RaceDistance(category: .half, type: .inPerson)),
      makeMedal(distance: RaceDistance(category: .half, type: .inPerson))
    ]

    #expect(medals.bestHalfTime == nil)
  }

  @Test("bestHalfTime returns the minimum finish time across half marathon medals")
  func testBestHalfTimeReturnsMinimum() {
    let medals: [Medal] = [
      makeMedal(distance: RaceDistance(category: .half, type: .inPerson), finishTime: 1800),
      makeMedal(distance: RaceDistance(category: .half, type: .inPerson), finishTime: 3600)
    ]

    #expect(medals.bestHalfTime == 1800)
  }
}
