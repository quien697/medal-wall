//
//  RaceDistanceCategoryGroupTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-17.
//

import Testing
import SwiftUI
@testable import MedalWall

struct RaceDistanceCategoryGroupTests {
  
  @Test("RawValue matches expected labels")
  func testRawValues() {
    #expect(RaceDistanceCategoryGroup.fun.rawValue == "Fun")
    #expect(RaceDistanceCategoryGroup.mini.rawValue == "Mini")
    #expect(RaceDistanceCategoryGroup.half.rawValue == "Half")
    #expect(RaceDistanceCategoryGroup.long.rawValue == "Long")
    #expect(RaceDistanceCategoryGroup.full.rawValue == "Full")
    #expect(RaceDistanceCategoryGroup.ultra.rawValue == "Ultra")
  }
  
  @Test("id returns rawValue")
  func testIdMatchesRawValue() {
    for group in RaceDistanceCategoryGroup.allCases {
      #expect(group.id == group.rawValue)
    }
  }
  
  @Test("Each group has a valid color")
  func testColorExists() {
    for group in RaceDistanceCategoryGroup.allCases {
      #expect(group.color.description.count > 0)
    }
  }
  
  @Test("All cases exist")
  func testAllCasesCount() {
    #expect(RaceDistanceCategoryGroup.allCases.count == 6)
  }
}
