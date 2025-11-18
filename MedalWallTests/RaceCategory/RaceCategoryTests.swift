//
//  RaceCategoryTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-17.
//

import Testing
import Foundation
import SwiftData
@testable import MedalWall

struct RaceCategoryTests {
  
  private func makeContainer() throws -> ModelContainer {
    let schema = Schema([Race.self, RaceCategory.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [modelConfiguration])
  }
  
  @Test("RaceCategory initializes correctly from RaceDistance")
  func testRaceCategoryInit() throws {
    let container = try makeContainer()
    let context = ModelContext(container)
    let race = Race(
      name: "Test Marathon",
      date: .now,
      location: RaceLocation(
        country: "Taipei",
        city: "Taipei"
      ),
      updateTime: .now,
    )
    context.insert(race)
    
    let distance = RaceDistance(category: .half, type: .inPerson)
    let category = RaceCategory(distance: distance, race: race)
    
    #expect(category.name == "21K")
    #expect(category.distance == 21.0975)
    #expect(category.type == "inPerson")
    #expect(category.race.name == race.name)
  }
  
  @Test("RaceCategory is attached to its parent Race")
  func testRelationship() throws {
    let container = try makeContainer()
    let context = ModelContext(container)
    let race = Race(
      name: "Test Marathon",
      date: .now,
      location: RaceLocation(
        country: "USA",
        province: "CA",
        city: "Los ANgeles",
        district: nil
      ),
      url: nil,
      updateTime: .now,
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
    #expect(fetchedRace.categories[0].type == "virtual")
  }
}
