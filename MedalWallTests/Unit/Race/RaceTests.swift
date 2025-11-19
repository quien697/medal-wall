//
//  RaceTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-17.
//

import Testing
import Foundation
@testable import MedalWall

struct RaceTests {
  
  @Test("Race initializes with correct stored properties")
  func testRaceInit() throws {
    let race = Race(
      name: "Taipei Marathon",
      date: .now,
      location: RaceLocation(
        country: "Taiwan",
        city: "Taipei"
      ),
    )
    
    #expect(race.name == "Taipei Marathon")
    #expect(race.country == "Taiwan")
    #expect(race.city == "Taipei")
    #expect(Sport(rawValue: race.sport)?.displayName == "Running")
    #expect(RaceType(rawValue: race.type)?.displayName == "Road")
  }
  
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
      )
    )
    let location = race.location
    
    #expect(location.country == "Japan")
    #expect(location.city == "Shinjuku")
    #expect(location.province == "Tokyo")
    #expect(location.district == "Nishi-Shinjuku")
  }
  
  @Test("Race.distances correctly converts RaceCategory → RaceDistance")
  func testRaceDistancesComputed() throws {
    let race = Race(
      name: "Sun Run Marathon",
      date: .now,
      location: RaceLocation(
        country: "Canada",
        province: "BC",
        city: "Vancouver"
      )
    )
    race.categories = [
      RaceCategory(
        distance: RaceDistance(category: .full, type: .inPerson),
        race: race
      ),
      RaceCategory(
        distance: RaceDistance(category: .half, type: .virtual),
        race: race
      )
    ]
    let distances = race.distances
    
    #expect(distances.count == 2)
    #expect(distances.map(\.category).contains(.full))
    #expect(distances.map(\.category).contains(.half))
    #expect(distances.map(\.type).contains(.inPerson))
    #expect(distances.map(\.type).contains(.virtual))
  }
}
