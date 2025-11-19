//
//  RaceEditViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-18.
//

import Testing
import Foundation
import SwiftData
@testable import MedalWall

struct RaceEditViewModelTests {

  @Test("Init loads existing race data")
  func testInitExistingRace() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    let race = Race(
      name: "Taipei Marathon",
      date: .now,
      location: RaceLocation(country: "Taiwan", city: "Taipei"),
      url: nil,
      updateTime: .now
    )
    context.insert(race)
    
    let category = RaceCategory(
      distance: RaceDistance.default,
      race: race
    )
    context.insert(category)
    race.categories = [category]
    
    let vm = RaceEditViewModel(race: race, context: context)
    
    #expect(vm.name == "Taipei Marathon")
    #expect(vm.country == "Taiwan")
    #expect(vm.city == "Taipei")
    #expect(vm.distances.count == 1)
  }
  
  @Test("Form validation works")
  func testFormValidation() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    let vm = RaceEditViewModel(race: nil, context: context)
    vm.name = ""
    vm.country = "Taiwan"
    vm.city = "Taipei"
    #expect(vm.isFormValid == false)
    
    vm.name = "Race"
    #expect(vm.isFormValid == true)
  }
  
  @Test("Add and delete distances")
  func testAddDeleteDistance() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    let vm = RaceEditViewModel(race: nil, context: context)
    vm.addDistance(RaceDistance.default)
    #expect(vm.distances.count == 1)
    
    vm.deleteDistance(at: IndexSet(integer: 0))
    #expect(vm.distances.isEmpty)
  }
  
  @Test("Saving a new race inserts it into context")
  func testSaveNewRace() throws {
    let schema = Schema([Race.self, RaceCategory.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    let vm = RaceEditViewModel(race: nil, context: context)
    vm.name = "Tokyo Marathon 2026"
    vm.country = "Japan"
    vm.city = "Tokyo"
    vm.distances = [
      RaceDistance(category: .full, type: .inPerson)
    ]
    try vm.save()
    
    let races = try context.fetch(FetchDescriptor<Race>())
    #expect(races.count == 1)
    #expect(races.first?.categories.count == 1)
    #expect(races.first?.name == "Tokyo Marathon 2026")
  }
  
  @Test("Saving updates existing race")
  func testSaveExistingRace() throws {
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
    
    let vm = RaceEditViewModel(race: race, context: context)
    vm.name = "Boston Marathon (after edit)"
    vm.city = "New York"
    vm.distances = [
      RaceDistance(category: .half, type: .virtual)
    ]
    try vm.save()
    
    #expect(race.name == "Boston Marathon (after edit)")
    #expect(race.city == "New York")
    #expect(race.categories.count == 1)
  }
}
