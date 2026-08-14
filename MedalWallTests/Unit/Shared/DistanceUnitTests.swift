//
//  DistanceUnitTests.swift
//  MedalWall
//
//  Created by Quien on 2026-08-13.
//

import Foundation
import Testing

@testable import MedalWall

struct DistanceUnitTests {

  // MARK: - Support
  /// A throwaway `UserDefaults` suite so tests never mutate `.standard`.
  private static func makeDefaults(
    distanceUnit: String?,
    appLanguage: String? = AppLanguage.english.rawValue,
    function: String = #function
  ) -> UserDefaults {
    let suiteName = "DistanceUnitTests.\(function).\(UUID().uuidString)"
    guard let defaults = UserDefaults(suiteName: suiteName) else {
      fatalError("Unable to create UserDefaults suite")
    }
    defaults.removePersistentDomain(forName: suiteName)
    if let distanceUnit {
      defaults.set(distanceUnit, forKey: DistanceUnit.storageKey)
    }
    if let appLanguage {
      defaults.set(appLanguage, forKey: AppLanguage.storageKey)
    }

    return defaults
  }

  // MARK: - label
  @Test("Only two units are offered — there is no System option")
  func testNoSystemOption() {
    #expect(DistanceUnit.allCases == [.kilometers, .miles])
    #expect(DistanceUnit(rawValue: "system") == nil)
  }

  @Test("Kilometers label")
  func testKilometersLabel() {
    #expect(DistanceUnit.kilometers.label == "Kilometers")
  }

  @Test("Miles label")
  func testMilesLabel() {
    #expect(DistanceUnit.miles.label == "Miles")
  }

  // MARK: - stored
  @Test("stored reads the persisted preference")
  func testStored() {
    let defaults = Self.makeDefaults(distanceUnit: DistanceUnit.miles.rawValue)

    #expect(DistanceUnit.stored(in: defaults) == .miles)
  }

  @Test("stored is nil when the user has never chosen")
  func testStoredUnset() {
    let defaults = Self.makeDefaults(distanceUnit: nil)

    #expect(DistanceUnit.stored(in: defaults) == nil)
  }

  @Test("stored is nil for an unrecognized stored value")
  func testStoredUnrecognized() {
    let defaults = Self.makeDefaults(distanceUnit: "furlongs")

    #expect(DistanceUnit.stored(in: defaults) == nil)
  }

  @Test("A legacy stored 'system' value is not honoured as a unit")
  func testStoredLegacySystem() {
    // Earlier builds persisted "system"; it must fall back to the device default rather
    // than being treated as a unit.
    let defaults = Self.makeDefaults(distanceUnit: "system")

    #expect(DistanceUnit.stored(in: defaults) == nil)
    #expect(DistanceUnit.resolved(from: defaults) == DistanceUnit.deviceDefault)
  }

  // MARK: - resolved
  @Test("resolved returns an explicit choice unchanged")
  func testResolvedExplicitChoice() {
    let kilometres = Self.makeDefaults(distanceUnit: DistanceUnit.kilometers.rawValue)
    let miles = Self.makeDefaults(distanceUnit: DistanceUnit.miles.rawValue)

    #expect(DistanceUnit.resolved(from: kilometres) == .kilometers)
    #expect(DistanceUnit.resolved(from: miles) == .miles)
  }

  @Test("resolved falls back to the device default before any choice")
  func testResolvedFallsBackToDevice() {
    let defaults = Self.makeDefaults(distanceUnit: nil)

    #expect(DistanceUnit.resolved(from: defaults) == DistanceUnit.deviceDefault)
  }

  @Test("An explicit choice outranks the device region")
  func testExplicitChoiceOutranksDevice() {
    // Whichever unit the device would give, the opposite one can be pinned.
    let opposite: DistanceUnit = DistanceUnit.deviceDefault == .miles ? .kilometers : .miles
    let defaults = Self.makeDefaults(distanceUnit: opposite.rawValue)

    #expect(DistanceUnit.resolved(from: defaults) == opposite)
  }

  // MARK: - measurement system mapping
  @Test("Metric regions resolve to kilometers")
  func testMetricResolvesToKilometers() {
    #expect(DistanceUnit.unit(for: .metric) == .kilometers)
  }

  @Test("US regions resolve to miles")
  func testUSResolvesToMiles() {
    #expect(DistanceUnit.unit(for: .us) == .miles)
  }

  @Test("UK regions resolve to miles, matching road-running convention")
  func testUKResolvesToMiles() {
    #expect(DistanceUnit.unit(for: .uk) == .miles)
  }

  @Test("A pinned language locale does not decide the unit")
  func testPinnedLanguageDoesNotDecideUnit() {
    // `Locale(identifier: "en")` carries no region, so it must never be the source
    // of a measurement system — a US user would silently get kilometres.
    let defaults = Self.makeDefaults(distanceUnit: nil)
    let deviceUnit = DistanceUnit.unit(for: Locale.autoupdatingCurrent.measurementSystem)

    #expect(DistanceUnit.resolved(from: defaults) == deviceUnit)
    #expect(DistanceUnit.deviceDefault == deviceUnit)
  }

  // MARK: - conversion
  @Test("Miles convert to kilometres by the exact international factor")
  func testMilesToKilometers() {
    #expect(DistanceUnit.miles.kilometers(fromDisplayValue: 10) == 16.09344)
    #expect(DistanceUnit.miles.kilometers(fromDisplayValue: 12) == 19.312128)
  }

  @Test("Kilometres pass through unconverted")
  func testKilometersPassThrough() {
    #expect(DistanceUnit.kilometers.kilometers(fromDisplayValue: 16.09) == 16.09)
    #expect(DistanceUnit.kilometers.displayValue(fromKilometers: 16.09) == 16.09)
  }

  @Test("A mile-entered distance round-trips exactly")
  func testMilesRoundTrip() {
    let stored = DistanceUnit.miles.kilometers(fromDisplayValue: 10)

    #expect(DistanceUnit.miles.displayValue(fromKilometers: stored) == 10)
  }

  // MARK: - formatted
  @Test("Full marathon formats in both units")
  func testFormattedFull() {
    #expect(Self.text(42.195, in: .kilometers) == "42.2 km")
    #expect(Self.text(42.195, in: .miles) == "26.2 mi")
  }

  @Test("Half marathon formats in both units")
  func testFormattedHalf() {
    #expect(Self.text(21.0975, in: .kilometers) == "21.1 km")
    #expect(Self.text(21.0975, in: .miles) == "13.1 mi")
  }

  @Test("Trailing zero is dropped")
  func testFormattedDropsTrailingZero() {
    #expect(Self.text(10, in: .kilometers) == "10 km")
    #expect(Self.text(10, in: .miles) == "6.2 mi")
  }

  @Test("A mile-entered custom distance formats as the number that was typed")
  func testFormattedCustom() {
    #expect(Self.text(16.09344, in: .kilometers) == "16.1 km")
    #expect(Self.text(16.09344, in: .miles) == "10 mi")
  }

  @Test("Zero formats without a malformed value")
  func testFormattedZero() {
    #expect(Self.text(0, in: .kilometers) == "0 km")
    #expect(Self.text(0, in: .miles) == "0 mi")
  }

  @Test("A negative distance formats without crashing")
  func testFormattedNegative() {
    #expect(Self.text(-5, in: .kilometers) == "-5 km")
    #expect(Self.text(-5, in: .miles) == "-3.1 mi")
  }

  // MARK: - customFieldLabel
  @Test("The custom field label names the active unit in English")
  func testCustomFieldLabelEnglish() {
    let defaults = Self.makeDefaults(distanceUnit: nil)

    #expect(DistanceUnit.miles.customFieldLabel(defaults: defaults) == "Custom distance (mi)")
    #expect(
      DistanceUnit.kilometers.customFieldLabel(defaults: defaults) == "Custom distance (km)"
    )
  }

  @Test("The custom field label composes both lookups from the same localization table")
  func testCustomFieldLabelTraditionalChinese() {
    // The format string and its interpolated unit are two separate catalog lookups; if
    // they resolved against different tables the result would mix scripts.
    let defaults = Self.makeDefaults(
      distanceUnit: nil,
      appLanguage: AppLanguage.zhTW.rawValue
    )

    #expect(DistanceUnit.kilometers.customFieldLabel(defaults: defaults) == "自訂距離（公里）")
    #expect(DistanceUnit.miles.customFieldLabel(defaults: defaults) == "自訂距離（英里）")
  }

  // MARK: - custom distance entry
  @Test("The custom field is seeded with the value the app displays")
  func testSeededDisplayValue() {
    #expect(DistanceUnit.miles.roundedDisplayValue(fromKilometers: 16.09) == 10)
    #expect(DistanceUnit.kilometers.roundedDisplayValue(fromKilometers: 16.09) == 16.1)
    #expect(DistanceUnit.miles.roundedDisplayValue(fromKilometers: 42.195) == 26.2)
  }

  @Test("An unedited custom distance keeps its original kilometres")
  func testUneditedCustomDistanceIsPreserved() {
    // 16.09 km seeds the miles field with a rounded 10; saving without editing must not
    // rewrite the stored value to 16.09344 — race editions are shared records.
    let saved = DistanceUnit.miles.customKilometers(
      displayValue: 10,
      originalKilometers: 16.09
    )

    #expect(saved == 16.09)
  }

  @Test("An unedited custom distance keeps its original kilometres in kilometres mode")
  func testUneditedCustomDistanceIsPreservedInKilometers() {
    let saved = DistanceUnit.kilometers.customKilometers(
      displayValue: 16.1,
      originalKilometers: 16.09
    )

    #expect(saved == 16.09)
  }

  @Test("An edited custom distance converts from the entered unit")
  func testEditedCustomDistanceConverts() {
    let saved = DistanceUnit.miles.customKilometers(
      displayValue: 12,
      originalKilometers: 16.09
    )

    #expect(saved == 19.312128)
  }

  @Test("A brand-new custom distance converts from the entered unit")
  func testNewCustomDistanceConverts() {
    #expect(
      DistanceUnit.miles.customKilometers(displayValue: 10, originalKilometers: nil)
        == 16.09344
    )
    #expect(
      DistanceUnit.kilometers.customKilometers(displayValue: 10, originalKilometers: nil)
        == 10
    )
  }

  @Test("A mile-entered near-preset distance is not snapped to the preset")
  func testNearPresetIsNotSnapped() {
    let saved = DistanceUnit.miles.customKilometers(
      displayValue: 26.2,
      originalKilometers: nil
    )

    #expect(saved == 42.1648128)
    #expect(RaceDistanceCategory(value: saved) == .custom(42.1648128))
  }

  /// Formats a canonical kilometre value under a pinned English locale, so number
  /// formatting does not vary with the simulator's region.
  private static func text(
    _ kilometers: Double,
    in unit: DistanceUnit,
    function: String = #function
  ) -> String {
    let defaults = makeDefaults(distanceUnit: unit.rawValue, function: function)

    return unit.formatted(kilometers: kilometers, defaults: defaults)
  }
}
