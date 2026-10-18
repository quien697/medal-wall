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

  // MARK: - formatted
  @Test("A standard distance formats its stored measurement")
  func testFormattedStandard() {
    #expect(Self.text(42.195, in: .kilometers) == "42.195 km")
    #expect(Self.text(21.0975, in: .kilometers) == "21.0975 km")
  }

  @Test("A mile distance formats as the miles that were stored")
  func testFormattedMiles() {
    #expect(Self.text(26.2, in: .miles) == "26.2 mi")
    #expect(Self.text(10, in: .miles) == "10 mi")
  }

  @Test("Trailing zero is dropped")
  func testFormattedDropsTrailingZero() {
    #expect(Self.text(10, in: .kilometers) == "10 km")
    #expect(Self.text(16.0, in: .kilometers) == "16 km")
  }

  @Test("A value with more than four decimals shows four")
  func testFormattedCapsAtFourDecimals() {
    #expect(Self.text(42.16481, in: .kilometers) == "42.1648 km")
  }

  /// The setting only sets the pace unit and where a new custom distance starts.
  @Test("The distance unit setting does not change how a distance formats")
  func testFormattedIgnoresSetting() {
    let defaults = Self.makeDefaults(distanceUnit: DistanceUnit.miles.rawValue)

    #expect(DistanceUnit.kilometers.formatted(value: 10, defaults: defaults) == "10 km")
  }

  @Test("Zero formats without a malformed value")
  func testFormattedZero() {
    #expect(Self.text(0, in: .kilometers) == "0 km")
    #expect(Self.text(0, in: .miles) == "0 mi")
  }

  @Test("A negative distance formats without crashing")
  func testFormattedNegative() {
    #expect(Self.text(-5, in: .kilometers) == "-5 km")
    #expect(Self.text(-5, in: .miles) == "-5 mi")
  }

  // MARK: - paceValueText
  @Test("paceValueText returns the value alone, with no unit")
  func testPaceValueTextHasNoUnit() {
    let defaults = Self.makeDefaults(distanceUnit: DistanceUnit.kilometers.rawValue)
    let pace = 5 + 41.0 / 60

    let value = DistanceUnit.kilometers.paceValueText(
      minutesPerUnit: pace,
      defaults: defaults
    )

    #expect(value == "5'41\"")
  }

  @Test("paceValueText truncates seconds the way paceText does")
  func testPaceValueTextTruncatesSeconds() {
    let defaults = Self.makeDefaults(distanceUnit: DistanceUnit.kilometers.rawValue)
    let pace = 4 + 59.9 / 60

    let value = DistanceUnit.kilometers.paceValueText(
      minutesPerUnit: pace,
      defaults: defaults
    )

    #expect(value == "4'59\"")
  }

  /// The pace is already calculated in miles, so converting it here would count it twice.
  @Test("paceValueText shows minutes per mile as given in miles mode")
  func testPaceValueTextMiles() {
    let defaults = Self.makeDefaults(distanceUnit: DistanceUnit.miles.rawValue)
    let pace = 5.0

    let value = DistanceUnit.miles.paceValueText(
      minutesPerUnit: pace,
      defaults: defaults
    )

    #expect(value == "5'00\"")
  }

  /// The unfilled wording belongs to the screen, not to a unit.
  @Test("paceValueText returns nil when there is no pace")
  func testPaceValueTextNil() {
    let defaults = Self.makeDefaults(distanceUnit: DistanceUnit.kilometers.rawValue)

    #expect(
      DistanceUnit.kilometers.paceValueText(minutesPerUnit: nil, defaults: defaults) == nil
    )
  }

  /// The minutes are taken with `Int(_:)`, which traps on a value it cannot hold, so a pace
  /// that is not a number, is negative, or is too large to show returns no pace instead.
  @Test(
    "paceValueText returns nil for a pace it cannot show",
    arguments: [Double.nan, .infinity, -5, 1e30])
  func testPaceValueTextNilWhenUnshowable(pace: Double) {
    let defaults = Self.makeDefaults(distanceUnit: DistanceUnit.kilometers.rawValue)

    #expect(
      DistanceUnit.kilometers.paceValueText(minutesPerUnit: pace, defaults: defaults) == nil
    )
  }

  // MARK: - paceText
  @Test("paceText joins the value with the unit abbreviation")
  func testPaceTextComposesValueAndUnit() {
    let defaults = Self.makeDefaults(distanceUnit: DistanceUnit.kilometers.rawValue)
    let pace = 5 + 41.0 / 60

    let value = DistanceUnit.kilometers.paceValueText(
      minutesPerUnit: pace,
      defaults: defaults
    )
    let joined = DistanceUnit.kilometers.paceText(
      minutesPerUnit: pace,
      defaults: defaults
    )

    #expect(joined == "5'41\" /km")
    #expect(joined == "\(value ?? "") /\(DistanceUnit.kilometers.abbreviation(defaults: defaults))")
  }

  /// Recomposing paceText must not disturb the placeholder its callers already pin.
  @Test("paceText keeps its own placeholder when there is no pace")
  func testPaceTextPlaceholderUnchanged() {
    let defaults = Self.makeDefaults(distanceUnit: DistanceUnit.kilometers.rawValue)

    #expect(
      DistanceUnit.kilometers.paceText(minutesPerUnit: nil, defaults: defaults)
        == "--'-- \""
    )
  }

  /// Formats a value already in `unit` under a pinned English locale, so number formatting
  /// does not vary with the simulator's region.
  private static func text(
    _ value: Double,
    in unit: DistanceUnit,
    function: String = #function
  ) -> String {
    let defaults = makeDefaults(distanceUnit: unit.rawValue, function: function)

    return unit.formatted(value: value, defaults: defaults)
  }
}
