//
//  RaceRepositoryIntegrationTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-30.
//

import Testing
import Foundation
import UIKit
import SwiftData
@testable import MedalWall

struct RaceRepositoryIntegrationTests {
  
  @Test("Insert a race")
  func testInsertRace() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    // test before
    let races = try context.fetch(FetchDescriptor<Race>())
    #expect(races.count == 0)
    
    let race = Race(
      name: "Tokyo Marathon",
      date: .now,
      location: RaceLocation(country: "Japan", city: "Tokyo"),
      url: nil,
      updateTime: .now
    )
    let repo = RaceRepository(context: context)
    
    try repo.insertRace(race)
    
    // test after
    let fetchedRaces = try context.fetch(FetchDescriptor<Race>())
    #expect(fetchedRaces.count == 1)
    #expect(fetchedRaces.first?.name == "Tokyo Marathon")
  }
  
  @Test("Insert a race with cateegories")
  func testInsertRaceWithCategories() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    // test before
    let races = try context.fetch(FetchDescriptor<Race>())
    #expect(races.count == 0)
    
    let race = Race(
      name: "London Marathon",
      date: .now,
      location: RaceLocation(country: "UK", city: "London"),
      url: nil,
      updateTime: .now
    )
    let distance = RaceDistance(category: .full, type: .inPerson)
    let category = RaceCategory(distance: distance, race: race)
    race.categories = [category]
    
    let repo = RaceRepository(context: context)
    try repo.insertRace(race)
    
    // test after
    let fetchedRaces = try context.fetch(FetchDescriptor<Race>())
    #expect(fetchedRaces.count == 1)
    #expect(fetchedRaces.first?.name == "London Marathon")
    #expect(fetchedRaces.first?.categories.count == 1)
  }
  
  @Test("Delete a race")
  func testDeleteRace() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    let race = Race(
      name: "Tokyo Marathon",
      date: .now,
      location: RaceLocation(country: "Japan", city: "Tokyo"),
      url: nil,
      updateTime: .now
    )
    let repo = RaceRepository(context: context)
    try repo.insertRace(race)
    
    // test before
    let races = try context.fetch(FetchDescriptor<Race>())
    #expect(races.count == 1)
    #expect(races.first?.name == "Tokyo Marathon")
    
    try repo.deleteRace(race)
    
    // test after
    let fetchedRaces = try context.fetch(FetchDescriptor<Race>())
    #expect(fetchedRaces.count == 0)
  }
  
  @Test("Delete a Race cascades its categories")
  func testDeleteRaceCascadeCategories() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    let race = Race(
      name: "London Marathon",
      date: .now,
      location: RaceLocation(country: "UK", city: "London"),
      url: nil,
      updateTime: .now
    )
    let distance = RaceDistance(category: .full, type: .inPerson)
    let category = RaceCategory(distance: distance, race: race)
    race.categories = [category]
    
    let repo = RaceRepository(context: context)
    try repo.insertRace(race)
    
    // test before
    let races = try context.fetch(FetchDescriptor<Race>())
    #expect(races.count == 1)
    #expect(races.first?.name == "London Marathon")
    #expect(races.first?.categories.count == 1)
    
    try repo.deleteRace(race)
    
    // test after
    let fetchedRaces = try context.fetch(FetchDescriptor<Race>())
    #expect(fetchedRaces.count == 0)
    
    let fetchedCategories = try context.fetch(FetchDescriptor<RaceCategory>())
    #expect(fetchedCategories.isEmpty)
  }
}
