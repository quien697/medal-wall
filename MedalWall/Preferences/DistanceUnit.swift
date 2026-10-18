//
//  DistanceUnit.swift
//  MedalWall
//
//  Created by Quien on 2026-08-13.
//

import Foundation

/// A unit of distance. A stored distance carries the unit it was entered in; as a preference,
/// the unit sets the pace unit and the starting unit for a new custom distance.
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

  /// Kilometres in one mile, by the international definition. Used in memory only, to compare
  /// real lengths and to work out pace across units; no distance is stored or shown converted.
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

  /// The unit set as the preference — the user's choice when they have made one, otherwise
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

  // MARK: - Formatting
  /// A value already in this unit rendered with up to four decimals, e.g. `"42.2 km"`.
  ///
  /// Nothing is converted: the number is shown as it was stored. Formats the number under
  /// the locale resolved from the app's *language* preference, and pairs it with a String
  /// Catalog abbreviation, rather than using `Measurement`/`UnitLength` — which would format
  /// against the device locale and choose its own translation of the unit name.
  func formatted(value: Double, defaults: UserDefaults = .standard) -> String {
    let number = value.formatted(
      .number
        .precision(.fractionLength(0...4))
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

  /// A pace in minutes per this unit, rendered without its unit — `5'41"`.
  ///
  /// Seconds are truncated, which is the app's long-standing behaviour. Returns `nil`
  /// rather than a placeholder when there is no pace: how an unrecorded value reads is a
  /// screen's decision, and a unit has no business holding one screen's wording.
  ///
  /// Exists so a caller that sets the value and the unit at different sizes can have both
  /// without splitting `paceText`'s output back apart on its punctuation.
  ///
  /// A pace that is not a number, is negative, or is too large for `Int(_:)` returns `nil`:
  /// `Int(_:)` traps on such a value, and a crash is worse than an unfilled pace.
  func paceValueText(
    minutesPerUnit pace: Double?,
    defaults: UserDefaults = .standard
  ) -> String? {
    guard let pace, pace.isFinite, pace >= 0, pace < Double(Int.max) else { return nil }
    let minutes = Int(pace)
    let seconds = Int((pace - Double(minutes)) * 60)

    return String(format: "%d'%02d\"", minutes, seconds)
  }

  /// A pace in minutes per this unit, rendered with its unit — `5'41" /km` or `9'08" /mi`.
  ///
  /// A nil pace returns `"--'-- \""` so a missing time still keeps the right shape.
  /// Composed from `paceValueText` so the pace format itself is written once.
  func paceText(minutesPerUnit pace: Double?, defaults: UserDefaults = .standard) -> String {
    guard let value = paceValueText(minutesPerUnit: pace, defaults: defaults) else {
      return "--'-- \""
    }

    return "\(value) /\(abbreviation(defaults: defaults))"
  }
}
