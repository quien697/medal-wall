//
//  RaceTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-17.
//

import Testing
import Foundation
import SwiftData
@testable import MedalWall

struct RaceTests {
  
  private func makeContainer() throws -> ModelContainer {
    let schema = Schema([Race.self, RaceCategory.self])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    return try ModelContainer(for: schema, configurations: [modelConfiguration])
  }
  
  // MARK: - Test stored properties
  @Test("Race initializes with correct stored properties")
  func testRaceInit() throws {
    let race = Race(
      name: "Taipei Marathon",
      photo: nil,
      date: .now,
      location: RaceLocation(
        country: "Taiwan",
        city: "Taipei"
      ),
      url: nil,
      updateTime: .now,
    )
    
    #expect(race.name == "Taipei Marathon")
    #expect(race.country == "Taiwan")
    #expect(race.city == "Taipei")
    #expect(Sport(rawValue: race.sport)?.displayName == "Running")
    #expect(RaceType(rawValue: race.type)?.displayName == "Road")
  }
  
  @Test("Race persists into SwiftData and retrieves correctly")
  func testRacePersistence() throws {
    let container = try makeContainer()
    let context = ModelContext(container)
    let race = Race(
      name: "Boston Marathon",
      date: .now,
      location: RaceLocation(
        country: "USA",
        province: "MA",
        city: "Boston",
        district: nil
      ),
      url: nil,
      updateTime: .now,
    )
    context.insert(race)
    try context.save()
    
    let fetched = try context.fetch(FetchDescriptor<Race>())
    let fetchedRace = fetched.first!
    
    #expect(fetched.count == 1)
    #expect(fetchedRace.name == "Boston Marathon")
  }
  
  @Test("Race updates correctly and persists changes")
  func testRaceEditing() throws {
    let container = try makeContainer()
    let context = ModelContext(container)
    let race = Race(
      name: "LA Marathon (before edit)",
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
  
  // MARK: - Test computed property
  @Test("Race.location builds a correct RaceLocation struct")
  func testRaceLocationComputed() {
    let race = Race(
      name: "Tokyo Marathon",
      date: .now,
      location: RaceLocation(
        country: "Japan",
        province: "Tokyo",
        city: "Shinjuku",
        district: "Nishi-Shinjuku"
      ),
      updateTime: .now
    )
    let location = race.location
    
    #expect(location.country == "Japan")
    #expect(location.city == "Shinjuku")
    #expect(location.province == "Tokyo")
    #expect(location.district == "Nishi-Shinjuku")
  }
  
  @Test("Race.distances correctly converts RaceCategory → RaceDistance")
  func testRaceDistancesComputed() throws {
    let container = try makeContainer()
    let context = ModelContext(container)
    let race = Race(
      name: "Sun Run Marathon",
      date: .now,
      location: RaceLocation(
        country: "Canada",
        province: "BC",
        city: "Vancouver"
      ),
      updateTime: .now
    )
    context.insert(race)
    
    let category1 = RaceCategory(distance: RaceDistance(category: .full, type: .inPerson), race: race)
    let category2 = RaceCategory(distance: RaceDistance(category: .half, type: .virtual), race: race)
    context.insert(category1)
    context.insert(category2)
    race.categories = [category1, category2]
    
    let distances = race.distances
    
    #expect(distances.count == 2)
    #expect(distances.map(\.category).contains(.full))
    #expect(distances.map(\.category).contains(.half))
    #expect(distances.map(\.type).contains(.inPerson))
    #expect(distances.map(\.type).contains(.virtual))
  }
}
