//
//  Place.swift
//  MedalWall
//
//  Created by Quien on 2026-05-18.
//

import Foundation

/// Represents where a race or medal took place, at `area level`.
///
/// `countryCode` is the only canonical field: it is the one value defined independently of
/// any map or geocoding provider, so it is the only one safe to group, filter, or join on.
/// `city` and `region` are display values — providers divide administrative levels
/// differently for the same place, so they disagree on which value is the city.
///
/// No coordinate is stored. A race's exact start line is published on its own site.
struct Place: Codable, Hashable, Sendable {
  /// ISO 3166-1 alpha-2, e.g. `"TW"`, `"CA"`, `"US"`. Empty when the provider supplied none.
  var countryCode: String
  var city: String
  var region: String?

  /// The place rendered for the current locale.
  var formatted: String {
    formatted(in: .current)
  }

  /// Whether the place carries the two fields a saved record needs. `region` is
  /// deliberately not required — most countries have none worth recording.
  var isValid: Bool {
    !countryCode.trimmingCharacters(in: .whitespaces).isEmpty
      && !city.trimmingCharacters(in: .whitespaces).isEmpty
  }

  /// Renders the place for `locale`, omitting every absent component so no empty separator
  /// or placeholder is left behind.
  func formatted(in locale: Locale) -> String {
    [city, region, locale.localizedString(forRegionCode: countryCode)]
      .compactMap { $0 }
      .filter { !$0.isEmpty }
      .joined(separator: ", ")
  }
}
