//
//  RaceDistanceCategoryTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-17.
//

import Testing
@testable import MedalWall

struct RaceDistanceCategoryTests {
  
  @Test("Description returns correct strings")
  func testDescription() {
    #expect(RaceDistanceCategory.full.description == "42K")
    #expect(RaceDistanceCategory.half.description == "21K")
    #expect(RaceDistanceCategory.`10K`.description == "10K")
    #expect(RaceDistanceCategory.`5K`.description == "5K")
    #expect(RaceDistanceCategory.custom(7).description == "7K")
    #expect(RaceDistanceCategory.custom(13.5).description == "13.5K")
    #expect(RaceDistanceCategory.custom(11.25).description == "11.25K")
    #expect(RaceDistanceCategory.custom(17.123).description == "17.123K")
    #expect(RaceDistanceCategory.custom(100).description == "100K")
  }
  
  @Test("Value returns correct numeric distance")
  func testValue() {
    #expect(RaceDistanceCategory.full.value == 42.195)
    #expect(RaceDistanceCategory.half.value == 21.0975)
    #expect(RaceDistanceCategory.`10K`.value == 10)
    #expect(RaceDistanceCategory.`5K`.value == 5)
    #expect(RaceDistanceCategory.custom(12.3).value == 12.3)
    #expect(RaceDistanceCategory.custom(8).value == 8)
  }
  
  @Test("Group classification is correct")
  func testGroupMapping() {
    #expect(RaceDistanceCategory.full.group == .full)
    #expect(RaceDistanceCategory.half.group == .half)
    #expect(RaceDistanceCategory.`10K`.group == .mini)
    #expect(RaceDistanceCategory.`5K`.group == .mini)
    
    #expect(RaceDistanceCategory.custom(4).group == .fun)
    #expect(RaceDistanceCategory.custom(5).group == .mini)
    #expect(RaceDistanceCategory.custom(15).group == .half)
    #expect(RaceDistanceCategory.custom(25).group == .long)
    #expect(RaceDistanceCategory.custom(40).group == .full)
    #expect(RaceDistanceCategory.custom(45).group == .ultra)
    
    #expect(RaceDistanceCategory.custom(3).group == .fun)
    #expect(RaceDistanceCategory.custom(7.23).group == .mini)
    #expect(RaceDistanceCategory.custom(17.5).group == .half)
    #expect(RaceDistanceCategory.custom(30).group == .long)
    #expect(RaceDistanceCategory.custom(43).group == .full)
    #expect(RaceDistanceCategory.custom(100).group == .ultra)
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
