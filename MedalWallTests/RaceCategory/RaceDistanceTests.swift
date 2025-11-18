//
//  RaceDistanceTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-17.
//

import Testing
@testable import MedalWall

struct RaceDistanceTests {
  
  @MainActor
  @Test("Default RaceDistance is .full & .inPerson")
  func testDefault() {
    let distance = RaceDistance.default
    #expect(distance.category == .full)
    #expect(distance.type == .inPerson)
  }
  
  @MainActor
  @Test("RaceDistance ID is unique")
  func testUniqueID() {
    let distance1 = RaceDistance.default
    let distance2 = RaceDistance.default
    #expect(distance1.id != distance2.id)
  }
  
  @MainActor
  @Test("sortedByDistance sorts by descending km")
  func testSortedByDistance() {
    let list: [RaceDistance] = [
      .init(category: .`5K`, type: .inPerson),
      .init(category: .half, type: .virtual),
      .init(category: .full, type: .inPerson)
    ]
    
    let sorted = list.sortedByDistance()
    
    #expect(sorted[0].category == .full)
    #expect(sorted[1].category == .half)
    #expect(sorted[2].category == .`5K`)
  }
  
  @MainActor
  @Test("sortedByTypeAndDistance sorts by type first, then distance")
  func testSortedByTypeAndDistance() {
    let list: [RaceDistance] = [
      .init(category: .full, type: .virtual),
      .init(category: .half, type: .inPerson),
      .init(category: .`10K`, type: .inPerson),
      .init(category: .`5K`, type: .virtual)
    ]
    
    let sorted = list.sortedByTypeAndDistance()
    
    // In-person first (alphabetical rawValue: inPerson < virtual)
    #expect(sorted[0].type == .inPerson)
    #expect(sorted[1].type == .inPerson)
    
    // Within in-person → full > half > 10K > 5K
    #expect(sorted[0].category == .half)
    #expect(sorted[1].category == .`10K`)
    
    // Then virtual distances
    #expect(sorted[2].type == .virtual)
    #expect(sorted[3].type == .virtual)
    
    // Within virtual → full > half > 10K > 5K
    #expect(sorted[2].category == .full)
    #expect(sorted[3].category == .`5K`)
  }
}
