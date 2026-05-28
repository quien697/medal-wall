//
//  RaceDistanceCategoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Testing

@testable import MedalWall

struct RaceDistanceCategoryTests {

  // MARK: - description
  @Test("Full marathon description is 42km")
  func testFullDescription() {
    #expect(RaceDistanceCategory.full.description == "42km")
  }

  @Test("Half marathon description is 21km")
  func testHalfDescription() {
    #expect(RaceDistanceCategory.half.description == "21km")
  }

  @Test("10KM description is 10km")
  func testTenKMDescription() {
    #expect(RaceDistanceCategory.tenKM.description == "10km")
  }

  @Test("5KM description is 5km")
  func testFiveKMDescription() {
    #expect(RaceDistanceCategory.fiveKM.description == "5km")
  }

  @Test("Custom whole-number distance description omits decimal")
  func testCustomWholeNumberDescription() {
    #expect(RaceDistanceCategory.custom(100).description == "100km")
  }

  @Test("Custom decimal distance description includes decimal")
  func testCustomDecimalDescription() {
    #expect(RaceDistanceCategory.custom(3.5).description == "3.5km")
  }

  @Test("Custom zero distance description is 0km")
  func testCustomZeroDescription() {
    #expect(RaceDistanceCategory.custom(0).description == "0km")
  }

  @Test("Custom negative distance description is -5km")
  func testCustomNegativeDescription() {
    #expect(RaceDistanceCategory.custom(-5).description == "-5km")
  }

  // MARK: - value
  @Test("Full marathon value is 42.195")
  func testFullValue() {
    #expect(RaceDistanceCategory.full.value == 42.195)
  }

  @Test("Half marathon value is 21.0975")
  func testHalfValue() {
    #expect(RaceDistanceCategory.half.value == 21.0975)
  }

  @Test("10KM value is 10")
  func testTenKMValue() {
    #expect(RaceDistanceCategory.tenKM.value == 10)
  }

  @Test("5KM value is 5")
  func testFiveKMValue() {
    #expect(RaceDistanceCategory.fiveKM.value == 5)
  }

  // MARK: - init(value:)
  @Test("init(value:) reconstructs full from 42.195")
  func testInitValueFull() {
    #expect(RaceDistanceCategory(value: 42.195) == .full)
  }

  @Test("init(value:) reconstructs half from 21.0975")
  func testInitValueHalf() {
    #expect(RaceDistanceCategory(value: 21.0975) == .half)
  }

  @Test("init(value:) reconstructs tenKM from 10")
  func testInitValueTenKM() {
    #expect(RaceDistanceCategory(value: 10) == .tenKM)
  }

  @Test("init(value:) reconstructs fiveKM from 5")
  func testInitValueFiveKM() {
    #expect(RaceDistanceCategory(value: 5) == .fiveKM)
  }

  @Test("init(value:) falls back to custom for unknown value")
  func testInitValueCustomFallback() {
    #expect(RaceDistanceCategory(value: 99) == .custom(99))
  }

  @Test("init(value:) falls back to custom for value close to but not matching full")
  func testInitValueNearFullFallback() {
    #expect(RaceDistanceCategory(value: 42.0) == .custom(42.0))
  }

  // MARK: - standardCases
  @Test("standardCases contains exactly full, half, tenKM, fiveKM in order")
  func testStandardCases() {
    let expected: [RaceDistanceCategory] = [.full, .half, .tenKM, .fiveKM]
    #expect(RaceDistanceCategory.standardCases == expected)
  }
}
