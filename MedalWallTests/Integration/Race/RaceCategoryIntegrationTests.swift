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
    context.insert(race)
    
    let distance = RaceDistance(category: .`10K`, type: .virtual)
    let category = RaceCategory(distance: distance, race: race)
    context.insert(category)
    race.categories.append(category)
    try context.save()
    
    let fetched = try context.fetch(FetchDescriptor<Race>())
    let fetchedRace = fetched.first!
    
    #expect(fetchedRace.categories.count == 1)
    #expect(fetchedRace.categories[0].name == "10K")
    #expect(fetchedRace.categories[0].distance == 10)
    #expect(fetchedRace.categories[0].type == "virtual")
  }
}
