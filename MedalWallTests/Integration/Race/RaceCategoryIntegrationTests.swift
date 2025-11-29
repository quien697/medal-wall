//
//  RaceCategoryIntegrationTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-19.
//

import Testing
import Foundation
import SwiftData
@testable import MedalWall

struct RaceCategoryIntegrationTests {
  
  @Test("RaceCategory is attached to its parent Race")
  func testRelationship() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    let race = Race(
      name: "Test Marathon",
      date: .now,
      location: RaceLocation(
        country: "USA",
        province: "CA",
        city: "Los ANgeles",
      ),
    )
    let distance = RaceDistance(category: .`10K`, type: .virtual)
    let category = RaceCategory(distance: distance, race: race)
    race.categories.append(category)
    context.insert(category)
    
    let fetchedRaces = try context.fetch(FetchDescriptor<Race>())
    #expect(fetchedRaces.count == 1)
    
    let fetchedRace = fetchedRaces.first!
    #expect(fetchedRace.categories.count == 1)
    
    let fetchedRaceCategory = fetchedRace.categories.first!
    #expect(fetchedRaceCategory.name == "10K")
    #expect(fetchedRaceCategory.distance == 10)
    #expect(fetchedRaceCategory.type == "virtual")
  }
}
