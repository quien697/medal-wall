//
//  RaceDistanceCategoryTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-17.
//

import Testing
import SwiftUI
@testable import MedalWall

struct RaceDistanceCategoryTests {
  
  @Test("Description returns correct strings")
  func testDescription() {
    #expect(RaceDistanceCategory.full.description == "42K")
    #expect(RaceDistanceCategory.half.description == "21K")
    #expect(RaceDistanceCategory.`10K`.description == "10K")
    #expect(RaceDistanceCategory.`5K`.description == "5K")
    #expect(RaceDistanceCategory.custom(7).description == "7.0K")
  }
  
  @Test("Value returns correct numeric distance")
  func testValue() {
    #expect(RaceDistanceCategory.full.value == 42.195)
    #expect(RaceDistanceCategory.half.value == 21.0975)
    #expect(RaceDistanceCategory.`10K`.value == 10)
    #expect(RaceDistanceCategory.`5K`.value == 5)
    #expect(RaceDistanceCategory.custom(12.3).value == 12.3)
  }
  
  @Test("Group classification is correct")
  func testGroupMapping() {
    #expect(RaceDistanceCategory.full.group == .full)
    #expect(RaceDistanceCategory.half.group == .half)
    #expect(RaceDistanceCategory.`10K`.group == .mini)
    #expect(RaceDistanceCategory.`5K`.group == .mini)
    #expect(RaceDistanceCategory.custom(3).group == .fun)
    #expect(RaceDistanceCategory.custom(7).group == .mini)
    #expect(RaceDistanceCategory.custom(17).group == .half)
    #expect(RaceDistanceCategory.custom(30).group == .long)
    #expect(RaceDistanceCategory.custom(43).group == .full)
    #expect(RaceDistanceCategory.custom(60).group == .ultra)
  }
  
  @Test("init(value:) maps exact matches")
  func testInitExactMatches() {
    #expect(RaceDistanceCategory(value: 42.195) == .full)
    #expect(RaceDistanceCategory(value: 21.0975) == .half)
    #expect(RaceDistanceCategory(value: 10) == .`10K`)
    #expect(RaceDistanceCategory(value: 5) == .`5K`)
    #expect(RaceDistanceCategory(value: 15.7) == .custom(15.7))
    #expect(RaceDistanceCategory(value: 25) == .custom(25))
  }
}
