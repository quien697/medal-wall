//
//  RacesViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-24.
//

import Testing
import Foundation
import SwiftData
@testable import MedalWall

struct RacesViewModelTests {
  
  @Test("Display all races")
  func testDisplayAll() {
    let races = RaceFactory.sampleData
    let filter = RaceFilter()
    let vm = RacesViewModel(races: races, filter: filter)
    let result = vm.visibleRaces
    
    #expect(result.count == 3)
  }
  
  @Test("Filter by distance type")
  func testFilterByType() {
    let races = RaceFactory.sampleData
    var filter = RaceFilter()
    filter.selectedTypes = [.inPerson]
    let vm = RacesViewModel(races: races, filter: filter)
    
    let result = vm.visibleRaces
    #expect(result.count == 2)
    #expect(result.contains(RaceFactory.taipei))
    #expect(result.contains(RaceFactory.tokyo))
  }
  
  @Test("Filter by distance category")
  func testFilterByCategory() {
    let races = RaceFactory.sampleData
    var filter = RaceFilter()
    filter.selectedCategories = [.full, .half]
    let vm = RacesViewModel(races: races, filter: filter)
    let result = vm.visibleRaces
    
    #expect(result.count == 2)
    #expect(result.contains(RaceFactory.taipei))
    #expect(result.contains(RaceFactory.vancouver))
  }
  
  @Test("Filter by type AND category")
  func testFilterCombined() {
    let races = RaceFactory.sampleData
    var filter = RaceFilter()
    filter.selectedCategories = [.full]
    filter.selectedTypes = [.inPerson]
    let vm = RacesViewModel(races: races, filter: filter)
    let result = vm.visibleRaces
    
    #expect(result.count == 1)
    #expect(result.first == RaceFactory.taipei)
  }
  
  @Test("Search filters by race name")
  func testSearch() {
    let races = RaceFactory.sampleData
    var filter = RaceFilter()
    filter.searchQuery = "tokyo"
    
    let vm = RacesViewModel(races: races, filter: filter)
    let result = vm.visibleRaces
    
    #expect(result.count == 1)
    #expect(result.first?.name == RaceFactory.tokyo.name)
  }
  
  @Test("Search + filter combination")
  func testSearchAndFilter() {
    let races = RaceFactory.sampleData
    var filter = RaceFilter()
    filter.selectedTypes = [.virtual]
    filter.searchQuery = "taipei"
    
    let vm = RacesViewModel(races: races, filter: filter)
    
    let result = vm.visibleRaces
    #expect(result.count == 1)
    #expect(result.first?.name == RaceFactory.taipei.name)
  }
}
