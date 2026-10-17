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
  /// A throwaway `UserDefaults` suite pinning a language and a distance unit, so number
  /// formatting does not vary with the simulator's region and `.standard` is never mutated.
  private static func makeDefaults(
    language: AppLanguage = .english,
    unit: DistanceUnit = .miles,
    function: String = #function
  ) -> UserDefaults {
    let suiteName = "RaceDistanceCategoryTests.\(function).\(UUID().uuidString)"
    guard let defaults = UserDefaults(suiteName: suiteName) else {
      fatalError("Unable to create UserDefaults suite")
    }
    defaults.removePersistentDomain(forName: suiteName)
    defaults.set(language.rawValue, forKey: AppLanguage.storageKey)
    defaults.set(unit.rawValue, forKey: DistanceUnit.storageKey)

    return defaults
  }

  /// The label under English, with the unit setting pinned to miles so a label that
  /// converted through the setting would show it.
  private static func label(
    _ category: RaceDistanceCategory,
    language: AppLanguage = .english,
    function: String = #function
  ) -> String {
    category.label(defaults: makeDefaults(language: language, function: function))
  }

  // MARK: - Recognition
  @Test("The standard distances are recognised by exact kilometre value")
  func testStandardsMatchExactly() {
    #expect(RaceDistanceCategory(value: 42.195, unit: .kilometers) == .full)
    #expect(RaceDistanceCategory(value: 21.0975, unit: .kilometers) == .half)
    #expect(RaceDistanceCategory(value: 10, unit: .kilometers) == .tenKM)
    #expect(RaceDistanceCategory(value: 5, unit: .kilometers) == .fiveKM)
  }

  @Test("The same number in miles is not a standard distance")
  func testSameNumberInMilesIsNotStandard() {
    let tenMiles = RaceDistanceCategory(value: 10, unit: .miles)

    #expect(tenMiles != .tenKM)
    #expect(!tenMiles.isStandard)
  }

  @Test("A near-standard distance is a custom distance")
  func testNearStandardIsCustom() {
    #expect(!RaceDistanceCategory(value: 42.2, unit: .kilometers).isStandard)
    #expect(!RaceDistanceCategory(value: 26.2, unit: .miles).isStandard)
    #expect(RaceDistanceCategory(value: 42.195, unit: .kilometers).isStandard)
  }

  // MARK: - kilometers
  @Test("A distance in miles converts to its real length in kilometres")
  func testMilesConvertToKilometers() {
    #expect(abs(RaceDistanceCategory(value: 10, unit: .miles).kilometers - 16.09344) < 1e-9)
  }

  @Test("A distance in kilometres is its own real length")
  func testKilometersStayKilometers() {
    #expect(RaceDistanceCategory.full.kilometers == 42.195)
  }

  // MARK: - label
  @Test("The standard distances are named whatever the unit setting")
  func testStandardsAreNamed() {
    #expect(Self.label(.full) == "Full")
    #expect(Self.label(.half) == "Half")
    #expect(Self.label(.tenKM) == "10K")
    #expect(Self.label(.fiveKM) == "5K")
  }

  @Test("The standard names localize")
  func testStandardNamesLocalize() {
    #expect(Self.label(.full, language: .zhTW) == "全馬")
    #expect(Self.label(.half, language: .zhTW) == "半馬")
  }

  @Test("A custom distance in kilometres reads as stored under the mile setting")
  func testCustomKilometersNotConverted() {
    #expect(Self.label(RaceDistanceCategory(value: 42.2, unit: .kilometers)) == "42.2 km")
  }

  @Test("A custom distance in miles reads as stored")
  func testCustomMilesNotConverted() {
    #expect(Self.label(RaceDistanceCategory(value: 10, unit: .miles)) == "10 mi")
  }

  @Test("A custom distance shows up to four decimals")
  func testCustomFourDecimals() {
    #expect(Self.label(RaceDistanceCategory(value: 12.3456, unit: .kilometers)) == "12.3456 km")
  }

  @Test("A custom whole number drops its trailing zeros")
  func testCustomWholeNumber() {
    #expect(Self.label(RaceDistanceCategory(value: 16, unit: .kilometers)) == "16 km")
  }

  @Test("A custom distance's unit localizes")
  func testCustomUnitLocalizes() {
    let label = Self.label(RaceDistanceCategory(value: 42.2, unit: .kilometers), language: .zhTW)

    #expect(label == "42.2 公里")
  }

  // MARK: - isValidCustom
  @Test("A positive value with up to four decimals is a valid custom distance")
  func testValidCustom() {
    #expect(RaceDistanceCategory(value: 10.1234, unit: .kilometers).isValidCustom)
    #expect(RaceDistanceCategory(value: 0.0001, unit: .miles).isValidCustom)
  }

  @Test("More than four decimals is not a valid custom distance")
  func testTooManyDecimals() {
    #expect(!RaceDistanceCategory(value: 10.12345, unit: .kilometers).isValidCustom)
  }

  @Test("Zero and negative values are not valid custom distances")
  func testNonPositive() {
    #expect(!RaceDistanceCategory(value: 0, unit: .kilometers).isValidCustom)
    #expect(!RaceDistanceCategory(value: -1, unit: .kilometers).isValidCustom)
  }

  @Test("A value that is not a finite number is not a valid custom distance")
  func testNonFinite() {
    #expect(!RaceDistanceCategory(value: .nan, unit: .kilometers).isValidCustom)
    #expect(!RaceDistanceCategory(value: .infinity, unit: .kilometers).isValidCustom)
  }

  // MARK: - standardCases
  @Test("standardCases lists the picker's presets longest first")
  func testStandardCases() {
    let expected: [RaceDistanceCategory] = [.full, .half, .tenKM, .fiveKM]
    #expect(RaceDistanceCategory.standardCases == expected)
  }
}
