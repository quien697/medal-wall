//
//  DistanceUnit.swift
//  MedalWall
//
//  Created by Quien on 2026-08-13.
//

import Foundation

/// The unit distances are displayed in.
///
/// Deliberately has no `system` case, unlike `AppTheme` and `AppLanguage`. A measurement
/// system is not a live OS setting users toggle, and `"system"` would be an ambiguous value
/// to persist — it means kilometres on a Taipei device and miles on a Denver one, so the
/// same stored preference would render differently per device and per client. The device
/// region seeds the initial value instead; only a concrete unit is ever stored.
nonisolated enum DistanceUnit: String, CaseIterable {
  case kilometers, miles

  /// The `@AppStorage` / `UserDefaults` key backing the distance unit preference.
  static let storageKey = "distanceUnit"

  /// Kilometres in one mile, by the international definition. Distances are stored in
  /// kilometres, so this is the only conversion constant the app needs.
  static let kilometersPerMile = 1.609344

  var label: String {
    switch self {
    case .kilometers: .appLocalized("Kilometers")
    case .miles: .appLocalized("Miles")
    }
  }

  // MARK: - Resolution
  /// The unit the device region implies, used until the user chooses for themselves.
  static var deviceDefault: DistanceUnit {
    unit(for: Locale.autoupdatingCurrent.measurementSystem)
  }

  /// The user's explicit choice, or `nil` if they have never made one.
  ///
  /// Also returns `nil` for an unrecognized raw value, which covers the `"system"` that
  /// earlier builds could persist — such a value falls back to the device rather than
  /// being honoured as a unit.
  static func stored(in defaults: UserDefaults = .standard) -> DistanceUnit? {
    guard let rawValue = defaults.string(forKey: storageKey) else { return nil }

    return DistanceUnit(rawValue: rawValue)
  }

  /// The unit the app displays in — the user's choice when they have made one, otherwise
  /// whatever the device region implies.
  static func resolved(from defaults: UserDefaults = .standard) -> DistanceUnit {
    stored(in: defaults) ?? deviceDefault
  }

  /// Maps a region's measurement system to the unit runners there use.
  ///
  /// The caller must pass the *device* region's measurement system, never one derived from
  /// `AppLanguage.resolvedLocale`: a pinned `Locale(identifier: "en")` carries no region,
  /// so its measurement system would silently hand a US user kilometres.
  ///
  /// `Locale.MeasurementSystem` is a struct rather than an enum, so the `default` is
  /// required by the compiler — it is not an unhandled case. UK is mixed in general but
  /// road running there is measured in miles.
  static func unit(for measurementSystem: Locale.MeasurementSystem) -> DistanceUnit {
    switch measurementSystem {
    case .us, .uk: .miles
    case .metric: .kilometers
    default: .kilometers
    }
  }

  // MARK: - Conversion
  /// Converts a canonical kilometre value into this unit, for display.
  func displayValue(fromKilometers kilometers: Double) -> Double {
    self == .miles ? kilometers / Self.kilometersPerMile : kilometers
  }

  /// Converts a value entered in this unit back to canonical kilometres, unrounded — full
  /// precision is what lets a mile-entered distance round-trip exactly.
  func kilometers(fromDisplayValue value: Double) -> Double {
    self == .miles ? value * Self.kilometersPerMile : value
  }

  /// The value the custom-distance field is seeded with — the same one-decimal figure the
  /// app displays everywhere else, so the field agrees with the labels around it.
  func roundedDisplayValue(fromKilometers kilometers: Double) -> Double {
    (displayValue(fromKilometers: kilometers) * 10).rounded() / 10
  }

  /// The kilometre value to persist for a custom distance edited in this unit.
  ///
  /// When the field still holds the rounded value it was seeded with, the original
  /// kilometres are returned untouched. Race editions are shared, globally readable
  /// records, so opening one in a different unit and saving without editing must not
  /// rewrite the stored number through the rounding used for display.
  func customKilometers(displayValue: Double, originalKilometers: Double?) -> Double {
    if let originalKilometers,
      displayValue == roundedDisplayValue(fromKilometers: originalKilometers)
    {
      return originalKilometers
    }

    return kilometers(fromDisplayValue: displayValue)
  }

  /// Converts a pace in minutes per kilometre into minutes per this unit.
  ///
  /// Pace converts the opposite way from a distance: covering a mile takes longer than
  /// covering a kilometre, so the per-mile figure is the larger one.
  func pace(fromMinutesPerKilometer minutes: Double) -> Double {
    self == .miles ? minutes * Self.kilometersPerMile : minutes
  }

  // MARK: - Formatting
  /// A canonical kilometre value rendered in this unit, e.g. `"26.2 mi"`.
  ///
  /// Formats the number under the locale resolved from the app's *language* preference,
  /// and pairs it with a String Catalog abbreviation, rather than using
  /// `Measurement`/`UnitLength` — which would format against the device locale and choose
  /// its own translation of the unit name.
  func formatted(kilometers: Double, defaults: UserDefaults = .standard) -> String {
    let value = displayValue(fromKilometers: kilometers)
    let number = value.formatted(
      .number
        .precision(.fractionLength(0...1))
        .locale(AppLanguage.resolvedLocale(from: defaults))
    )

    return "\(number) \(abbreviation(defaults: defaults))"
  }

  /// The localized unit abbreviation — `"km"` or `"mi"`.
  func abbreviation(defaults: UserDefaults = .standard) -> String {
    self == .miles
      ? .appLocalized("mi", defaults: defaults)
      : .appLocalized("km", defaults: defaults)
  }

  /// The custom-distance field's label — `"Custom distance (mi)"`.
  ///
  /// Composes two catalog lookups, so both must resolve against the *same* preferences;
  /// threading one `defaults` through prevents the format string and its argument being
  /// read from different localization tables.
  func customFieldLabel(defaults: UserDefaults = .standard) -> String {
    .appLocalized(
      "Custom distance (\(abbreviation(defaults: defaults)))",
      defaults: defaults
    )
  }
}
