//
//  RaceDistanceCategory.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
//

import Foundation

/// A race distance: the number and the unit it was entered in, stored and shown as they are.
///
/// The four standard distances are fixed kilometre values, so a custom distance with the same
/// number and unit is that standard distance by plain equality.
nonisolated struct RaceDistanceCategory: CustomStringConvertible, Hashable {
  var value: Double
  var unit: DistanceUnit

  static let full = RaceDistanceCategory(value: 42.195, unit: .kilometers)
  static let half = RaceDistanceCategory(value: 21.0975, unit: .kilometers)
  static let tenKM = RaceDistanceCategory(value: 10, unit: .kilometers)
  static let fiveKM = RaceDistanceCategory(value: 5, unit: .kilometers)

  /// The preset distances shown in the distance picker, longest first.
  static var standardCases: [RaceDistanceCategory] {
    [.full, .half, .tenKM, .fiveKM]
  }

  /// Whether this is one of the four standard distances.
  var isStandard: Bool {
    Self.standardCases.contains(self)
  }

  /// The real length in kilometres, for sorting and pace. Never shown or stored.
  var kilometers: Double {
    unit == .miles ? value * DistanceUnit.kilometersPerMile : value
  }

  /// Whether this can be saved as a custom distance: greater than zero, a finite number, and
  /// at most four decimals.
  ///
  /// The decimal check compares against the value rounded to four places with a tolerance,
  /// because a `Double` such as `10.1234` is not exactly four decimals in binary.
  var isValidCustom: Bool {
    guard value.isFinite, value > 0 else { return false }
    let rounded = (value * 10_000).rounded() / 10_000

    return abs(value - rounded) < 1e-9
  }

  /// The label shown in the UI.
  var description: String {
    label()
  }

  /// A standard distance's name, or any other distance's stored number and unit.
  ///
  /// The distance unit setting plays no part: a distance always reads as it was entered.
  func label(defaults: UserDefaults = .standard) -> String {
    switch self {
    case .full: .appLocalized("Full", defaults: defaults)
    case .half: .appLocalized("Half", defaults: defaults)
    case .tenKM: .appLocalized("10K", defaults: defaults)
    case .fiveKM: .appLocalized("5K", defaults: defaults)
    default: unit.formatted(value: value, defaults: defaults)
    }
  }
}
