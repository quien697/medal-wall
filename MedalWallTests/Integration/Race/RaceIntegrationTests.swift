//
//  RaceIntegrationTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-19.
//

import Testing
import Foundation
import SwiftData
@testable import MedalWall

struct RaceIntegrationTests {
  
  @Test("Race persists into SwiftData and retrieves correctly")
  func testRacePersistence() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    // test before
    let races = try context.fetch(FetchDescriptor<Race>())
    #expect(races.count == 0)
    
    let race = Race(
      name: "Boston Marathon",
      date: .now,
      location: RaceLocation(
        country: "USA",
        province: "MA",
        city: "Boston",
      ),
      url: "https://www.baa.org/races/boston-marathon/",
    )
    context.insert(race)
    
    // test after
    let fetchedRaces = try context.fetch(FetchDescriptor<Race>())
    #expect(fetchedRaces.count == 1)
    
    let fetchedRace = fetchedRaces.first!
    #expect(fetchedRace.name == "Boston Marathon")
    #expect(fetchedRace.country == "USA")
    #expect(fetchedRace.city == "Boston")
    #expect(fetchedRace.url == "https://www.baa.org/races/boston-marathon/")
  }
  
  @Test("Race updates correctly and persists changes")
  func testRaceEdit() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    let race = Race(
      name: "LA Marathon (before edit)",
      date: .now,
      location: RaceLocation(
        country: "USA",
        province: "CA",
        city: "Los ANgeles",
      ),
    )
    context.insert(race)
    
    // test before
    let races = try context.fetch(FetchDescriptor<Race>())
    #expect(races.count == 1)
    #expect(races.first?.name == "LA Marathon (before edit)")
    
    race.name = "LA Marathon (after edit)"
    race.city = "Seattle"
    race.updateTime = .now
    try context.save()
    
    // test after
    let fetchedRaces = try context.fetch(FetchDescriptor<Race>())
    #expect(fetchedRaces.count == 1)
    
    let fetchedRace = fetchedRaces.first!
    #expect(fetchedRace.name == "LA Marathon (after edit)")
    #expect(fetchedRace.city == "Seattle")
  }
}
