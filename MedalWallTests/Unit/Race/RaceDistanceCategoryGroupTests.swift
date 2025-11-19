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
}
