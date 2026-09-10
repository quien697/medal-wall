//
//  MedalPersonalBestTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-08.
//

import Foundation
import Testing

@testable import MedalWall

struct MedalPersonalBestTests {

  private func makeMedal(
    name: String = "Test",
    category: RaceDistanceCategory = .full,
    finishTime: TimeInterval? = nil
  ) -> Medal {
    Medal(
      name: name,
      date: .now,
      bibNumber: "1",
      place: Place(countryCode: "CA", city: "Vancouver"),
      distance: RaceDistance(category: category, type: .inPerson),
      finishTime: finishTime,
      userID: "user1"
    )
  }

  // MARK: - Identifiable
  @Test("id is the category's distance")
  func testIDIsTheCategoryValue() {
    let best = MedalPersonalBest(category: .full, medal: makeMedal())

    #expect(best.id == RaceDistanceCategory.full.value)
  }

  @Test("Two entries at the same distance share an id whichever medal holds the record")
  func testSameDistanceSharesIDAcrossMedals() {
    let first = MedalPersonalBest(category: .half, medal: makeMedal(name: "Older"))
    let second = MedalPersonalBest(category: .half, medal: makeMedal(name: "Faster"))

    #expect(first.id == second.id)
  }

  @Test("Two entries at different distances carry distinct ids")
  func testDifferentDistancesHaveDistinctIDs() {
    let full = MedalPersonalBest(category: .full, medal: makeMedal())
    let half = MedalPersonalBest(category: .half, medal: makeMedal(category: .half))

    #expect(full.id != half.id)
  }

  @Test("A custom distance equal to a preset shares that preset's id")
  func testCustomDistanceSharesPresetID() {
    let preset = MedalPersonalBest(category: .full, medal: makeMedal())
    let custom = MedalPersonalBest(
      category: .custom(42.195),
      medal: makeMedal(category: .custom(42.195))
    )

    #expect(preset.id == custom.id)
  }

  // MARK: - Contents
  @Test("An entry holds the medal it was built with")
  func testEntryHoldsItsMedal() {
    let medal = makeMedal(name: "Taipei Marathon 2019", finishTime: 3 * 3600)
    let best = MedalPersonalBest(category: .full, medal: medal)

    #expect(best.medal.id == medal.id)
  }
}
