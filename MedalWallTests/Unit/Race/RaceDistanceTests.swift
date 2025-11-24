//
//  RaceDistanceTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-17.
//

import Testing
@testable import MedalWall

struct RaceDistanceTests {
  
  @Test("Default RaceDistance is .full & .inPerson")
  func testDefault() {
    let distance = RaceDistance.default
    
    #expect(distance.category == .full)
    #expect(distance.type == .inPerson)
  }
  
  @Test("RaceDistance ID is unique")
  func testUniqueID() {
    let a = RaceDistance.default
    let b = RaceDistance.default
    
    #expect(a.id != b.id)
  }
  
  // MARK: - Compare
  @Test("Different types are not equal even if distance same")
  func testDifferentTypes() {
    let a = RaceDistance(category: .`10K`, type: .inPerson)
    let b = RaceDistance(category: .custom(10), type: .virtual)
    
    #expect(a != b)
  }
  
  @Test("Different distances are not equal")
  func testDifferentDistances() {
    let a = RaceDistance(category: .half, type: .inPerson) // .half = 21.0975
    let b = RaceDistance(category: .custom(21), type: .inPerson)
    
    #expect(a != b)
  }
  
  @Test("Hash values match when RaceDistance is equal")
  func testHashEquality1() {
    let a = RaceDistance(category: .full, type: .inPerson)
    let b = RaceDistance(category: .full, type: .inPerson)
    
    #expect(a.hashValue == b.hashValue)
  }
  
  @Test("Hash values match when RaceDistance is equal")
  func testHashEquality2() {
    let a = RaceDistance(category: .`10K`, type: .inPerson) // .`10K` = 10
    let b = RaceDistance(category: .custom(10), type: .inPerson)
    
    #expect(a.hashValue == b.hashValue)
  }
  
  @Test("Hash values differ when RaceDistance is not equal")
  func testHashInequality() {
    let a = RaceDistance(category: .`10K`, type: .inPerson) // .`10K`
    let b = RaceDistance(category: .custom(11), type: .inPerson)
    
    #expect(a.hashValue != b.hashValue)
  }
  
  // MARK: - Extension
  @Test("sortedByDistance sorts by descending km")
  func testSortedByDistance() {
    let distances: [RaceDistance] = [
      .init(category: .`5K`, type: .inPerson),
      .init(category: .half, type: .virtual),
      .init(category: .full, type: .inPerson)
    ]
    let sorted = distances.sortedByDistance()
    
    #expect(sorted[0].category == .full)
    #expect(sorted[1].category == .half)
    #expect(sorted[2].category == .`5K`)
  }
  
  @Test("sortedByTypeAndDistance sorts by type first, then distance")
  func testSortedByTypeAndDistance() {
    let distances: [RaceDistance] = [
      .init(category: .full, type: .virtual),
      .init(category: .half, type: .inPerson),
      .init(category: .`10K`, type: .inPerson),
      .init(category: .`5K`, type: .virtual)
    ]
    let sorted = distances.sortedByTypeAndDistance()
    
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
  
  @Test("groupedByType groups distances correctly")
  func testGrouped() {
    let distances: [RaceDistance] = [
      .init(category: .full, type: .inPerson),
      .init(category: .half, type: .inPerson),
      .init(category: .`10K`, type: .inPerson),
      .init(category: .custom(30.5), type: .virtual),
      .init(category: .half, type: .virtual)
    ]
    let grouped = distances.groupedByType()
    
    // Keys exist
    #expect(grouped.keys.contains(.inPerson))
    #expect(grouped.keys.contains(.virtual))
    
    // Group counts
    #expect(grouped[.inPerson]?.count == 3)
    #expect(grouped[.virtual]?.count == 2)
    
    // 3. Sorted order
    let inPerson = grouped[.inPerson]!
    #expect(inPerson[0].category.value == 42.195)
    #expect(inPerson[1].category.value == 21.0975)
    #expect(inPerson[2].category.value == 10)
    
    let virtual = grouped[.virtual]!
    #expect(virtual[0].category.value == 30.5)
    #expect(virtual[1].category.value == 21.0975)
  }
  
  @Test("groupedByType handles empty array")
  func testGroupedEmpty() {
    let distances: [RaceDistance] = []
    let grouped = distances.groupedByType()
    
    #expect(grouped.isEmpty)
  }
}
