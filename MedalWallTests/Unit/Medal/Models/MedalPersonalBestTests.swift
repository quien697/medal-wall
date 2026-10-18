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
      raceEvent: RaceEvent(category: category, type: .inPerson),
      result: finishTime.map(RaceResult.seconds),
      userID: "user1"
    )
  }

  // MARK: - Identifiable
  @Test("id is the category")
  func testIDIsTheCategory() {
    let best = MedalPersonalBest(category: .full, medal: makeMedal())

    #expect(best.id == .full)
  }

  @Test("10K and 10 mi entries carry distinct ids")
  func testSameNumberInDifferentUnitsHasDistinctIDs() {
    let tenMiles = RaceDistanceCategory(value: 10, unit: .miles)
    let tenK = MedalPersonalBest(category: .tenKM, medal: makeMedal(category: .tenKM))
    let tenMi = MedalPersonalBest(category: tenMiles, medal: makeMedal(category: tenMiles))

    #expect(tenK.id != tenMi.id)
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

  @Test("A custom distance of exactly a standard shares that standard's id")
  func testCustomDistanceSharesPresetID() {
    let preset = MedalPersonalBest(category: .full, medal: makeMedal())
    let custom = MedalPersonalBest(
      category: RaceDistanceCategory(value: 42.195, unit: .kilometers),
      medal: makeMedal(category: RaceDistanceCategory(value: 42.195, unit: .kilometers))
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
