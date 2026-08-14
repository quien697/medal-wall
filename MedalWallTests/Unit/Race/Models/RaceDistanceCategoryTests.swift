//
//  RaceDistanceCategoryTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Foundation
import Testing

@testable import MedalWall

struct RaceDistanceCategoryTests {

  // MARK: - Support
  /// A throwaway `UserDefaults` suite pinning English, so number formatting does not
  /// vary with the simulator's region and `.standard` is never mutated.
  private static func makeDefaults(function: String = #function) -> UserDefaults {
    let suiteName = "RaceDistanceCategoryTests.\(function).\(UUID().uuidString)"
    guard let defaults = UserDefaults(suiteName: suiteName) else {
      fatalError("Unable to create UserDefaults suite")
    }
    defaults.removePersistentDomain(forName: suiteName)
    defaults.set(AppLanguage.english.rawValue, forKey: AppLanguage.storageKey)

    return defaults
  }

  private static func label(
    _ category: RaceDistanceCategory,
    in unit: DistanceUnit,
    function: String = #function
  ) -> String {
    category.label(in: unit, defaults: makeDefaults(function: function))
  }

  // MARK: - label presets
  @Test("Full marathon is named, not measured, in both units")
  func testFullLabel() {
    #expect(Self.label(.full, in: .kilometers) == "Full")
    #expect(Self.label(.full, in: .miles) == "Full")
  }

  @Test("Half marathon is named, not measured, in both units")
  func testHalfLabel() {
    #expect(Self.label(.half, in: .kilometers) == "Half")
    #expect(Self.label(.half, in: .miles) == "Half")
  }

  @Test("10K keeps its name in both units — never 6.2mi")
  func testTenKMLabel() {
    #expect(Self.label(.tenKM, in: .kilometers) == "10K")
    #expect(Self.label(.tenKM, in: .miles) == "10K")
  }

  @Test("5K keeps its name in both units — never 3.1mi")
  func testFiveKMLabel() {
    #expect(Self.label(.fiveKM, in: .kilometers) == "5K")
    #expect(Self.label(.fiveKM, in: .miles) == "5K")
  }

  // MARK: - label custom
  @Test("Custom whole-number distance omits the decimal")
  func testCustomWholeNumberLabel() {
    #expect(Self.label(.custom(100), in: .kilometers) == "100 km")
  }

  @Test("Custom decimal distance keeps one fraction digit")
  func testCustomDecimalLabel() {
    #expect(Self.label(.custom(3.5), in: .kilometers) == "3.5 km")
  }

  @Test("A mile-entered custom distance reads back as the number that was typed")
  func testCustomMilesLabel() {
    #expect(Self.label(.custom(16.09344), in: .miles) == "10 mi")
    #expect(Self.label(.custom(16.09344), in: .kilometers) == "16.1 km")
  }

  @Test("Custom zero distance labels without a malformed value")
  func testCustomZeroLabel() {
    #expect(Self.label(.custom(0), in: .kilometers) == "0 km")
  }

  @Test("Custom negative distance labels without crashing")
  func testCustomNegativeLabel() {
    #expect(Self.label(.custom(-5), in: .kilometers) == "-5 km")
  }

  // MARK: - description
  @Test("description delegates to label using the stored preference")
  func testDescriptionDelegates() {
    let resolved = DistanceUnit.resolved()

    #expect(RaceDistanceCategory.full.description == RaceDistanceCategory.full.label(in: resolved))
    #expect(
      RaceDistanceCategory.custom(16.09344).description
        == RaceDistanceCategory.custom(16.09344).label(in: resolved)
    )
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
