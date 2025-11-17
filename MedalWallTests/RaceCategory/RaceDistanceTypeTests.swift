//
//  RaceDistanceTypeTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-17.
//

import Testing
@testable import MedalWall

struct RaceDistanceTypeTests {
  @Test("id returns rawValue")
  func testIdMatchesRawValue() {
    for group in RaceDistanceCategoryGroup.allCases {
      #expect(group.id == group.rawValue)
    }
  }
  
  @Test("RawValue matches expected labels")
  func testRawValues() {
    #expect(RaceDistanceType.inPerson.displayName == "In-person")
    #expect(RaceDistanceType.virtual.displayName == "Virtual")
  }
}
