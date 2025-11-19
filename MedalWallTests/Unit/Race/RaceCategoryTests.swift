//
//  RaceCategoryTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-19.
//

import Testing
import Foundation
@testable import MedalWall

struct RaceCategoryTests {
  
  @Test("RaceCategory initializes correctly from RaceDistance")
  func testRaceCategoryInit() throws {
    let race = Race(
      name: "Test Marathon",
      date: .now,
      location: RaceLocation(
        country: "Taipei",
        city: "Taipei"
      ),
    )
    let distance = RaceDistance(category: .half, type: .inPerson)
    let category = RaceCategory(distance: distance, race: race)
    
    #expect(category.name == "21K")
    #expect(category.distance == 21.0975)
    #expect(category.type == "inPerson")
    #expect(category.race.name == "Test Marathon")
  }
}
