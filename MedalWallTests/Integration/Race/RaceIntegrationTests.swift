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
    try context.save()
    
    let fetched = try context.fetch(FetchDescriptor<Race>())
    let fetchedRace = fetched.first!
    
    #expect(fetched.count == 1)
    #expect(fetchedRace.name == "Boston Marathon")
    #expect(fetchedRace.country == "USA")
    #expect(fetchedRace.city == "Boston")
    #expect(fetchedRace.url == "https://www.baa.org/races/boston-marathon/")
  }
  
  @Test("Race updates correctly and persists changes")
  func testRaceEditing() throws {
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
    try context.save()
    
    race.name = "LA Marathon (after edit)"
    race.city = "Seattle"
    race.updateTime = .now
    try context.save()
    
    let fetched = try context.fetch(FetchDescriptor<Race>())
    let updated = fetched.first!
    
    #expect(updated.name == "LA Marathon (after edit)")
    #expect(updated.city == "Seattle")
  }
}
