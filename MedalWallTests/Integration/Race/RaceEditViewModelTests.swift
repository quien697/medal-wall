//
//  RaceEditViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-18.
//

import Testing
import Foundation
import UIKit
import SwiftData
@testable import MedalWall

struct RaceEditViewModelTests {
  
  @Test("Form validation works")
  func testFormValidation() throws {
    let vm = RaceEditViewModel(race: nil)
    vm.name = ""
    vm.country = "Taiwan"
    vm.city = "Taipei"
    #expect(vm.isFormValid == false)
    
    vm.name = "Race"
    #expect(vm.isFormValid == true)
  }
  
  @Test("Update race photo")
  func testUpdateRacePhoto() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    let race = Race(
      name: "Taipei Marathon",
      date: .now,
      location: .init(country: "Taiwan", city: "Taipei"),
      url: nil
    )
    context.insert(race)
    
    // test before
    let races = try context.fetch(FetchDescriptor<Race>())
    #expect(races.count == 1)
    #expect(races.first?.photoData == nil)
    
    let vm = RaceEditViewModel(race: race)
    vm.attachContext(context)
    vm.photoData = "image".data(using: .utf8)
    
    try vm.save()
    
    // test after
    let fetchedRaces = try context.fetch(FetchDescriptor<Race>())
    #expect(fetchedRaces.count == 1)
    #expect(fetchedRaces.first?.photoData == "image".data(using: .utf8))
  }
  
  @Test("Clear race photo")
  func testClearRacePhoto() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    let race = Race(
      name: "Taipei Marathon",
      date: .now,
      location: .init(country: "Taiwan", city: "Taipei"),
      url: nil
    )
    race.photoData = "image".data(using: .utf8)
    context.insert(race)
    
    // test before
    let races = try context.fetch(FetchDescriptor<Race>())
    #expect(races.count == 1)
    #expect(races.first?.photoData != nil)
    
    let vm = RaceEditViewModel(race: race)
    vm.attachContext(context)
    vm.photoData = nil
    
    try vm.save()
    
    // test after
    let fetchedRaces = try context.fetch(FetchDescriptor<Race>())
    #expect(fetchedRaces.count == 1)
    #expect(fetchedRaces.first?.photoData == nil)
  }
  
  @Test("Add distances with the correct value")
  func testAddDistance() throws {
    let vm = RaceDistanceFactory()
    #expect(vm.distances.count == 5)
    
    try vm.addDistance(RaceDistance(category: .custom(33), type: .virtual))
    
    #expect(vm.distances.count == 6)
  }
  
  @Test("Add distances should throw duplicate error")
  func testAddDistanceThrowDuplicateError() throws {
    let vm = RaceDistanceFactory()

    #expect(throws: RaceEditError.duplicateDistance) {
      try vm.addDistance(RaceDistance.default)
    }
  }
  
  @Test("Updating a distance replaces the correct value")
  func testUpdateDistance() throws {
    let vm = RaceDistanceFactory()
    let old = vm.distances[1]
    let new = RaceDistance(category: .custom(25), type: .inPerson)
    
    try vm.updateDistance(old: old, with: new)
    
    #expect(vm.distances.count == 5)
    #expect(vm.distances.contains(new))
  }
  
  @Test("Updating to an existing distance should throw duplicate error")
  func testUpdateDistanceThrowDuplicateError() throws {
    let vm = RaceDistanceFactory()
    let old = vm.distances[1]
    let new = vm.distances[0]
    
    #expect(throws: RaceEditError.duplicateDistance) {
      try vm.updateDistance(old: old, with: new)
    }
  }
  
  @Test("Delete distances")
  func testDeleteDistance() throws {
    let vm = RaceDistanceFactory()
    let distance = RaceDistance(category: .`5K`, type: .inPerson)
    
    vm.deleteDistance(distance)
    
    #expect(vm.distances.count == 4)
    #expect(!vm.distances.contains(distance))
  }
  
  @Test("Saving a new race")
  func testAddNewRace() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    // test before
    let races = try context.fetch(FetchDescriptor<Race>())
    #expect(races.count == 0)
    
    let vm = RaceEditViewModel(race: nil)
    vm.attachContext(context)
    vm.name = "Tokyo Marathon 2026"
    vm.country = "Japan"
    vm.city = "Tokyo"
    vm.distances = [
      RaceDistance(category: .full, type: .inPerson)
    ]
    
    try vm.save()
    
    // test after
    let fetchedRaces = try context.fetch(FetchDescriptor<Race>())
    #expect(fetchedRaces.count == 1)
    
    let fetchedRace = fetchedRaces.first!
    #expect(fetchedRace.categories.count == 1)
    #expect(fetchedRace.name == "Tokyo Marathon 2026")
  }
  
  @Test("Updates existing race and save")
  func testSaveExistRace() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    let race = Race(
      name: "Boston Marathon (before edit)",
      date: .now,
      location: RaceLocation(country: "USA", province: "MA", city: "Boston"),
      url: nil,
      updateTime: .now
    )
    context.insert(race)
    
    // test before
    let races = try context.fetch(FetchDescriptor<Race>())
    #expect(races.count == 1)
    #expect(races.first?.name == "Boston Marathon (before edit)")
    
    let vm = RaceEditViewModel(race: race)
    vm.attachContext(context)
    vm.name = "Boston Marathon (after edit)"
    vm.city = "New York"
    vm.distances = [
      RaceDistance(category: .half, type: .virtual)
    ]
    
    try vm.save()
    
    // test after
    let fetchedRaces = try context.fetch(FetchDescriptor<Race>())
    #expect(fetchedRaces.count == 1)
    
    let fetchedRace = fetchedRaces.first!
    #expect(fetchedRace.name == "Boston Marathon (after edit)")
    #expect(fetchedRace.city == "New York")
    #expect(fetchedRace.categories.count == 1)
  }
}
