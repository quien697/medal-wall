//
//  AppLanguage.swift
//  MedalWall
//
//  Created by Quien on 2026-08-11.
//

import Foundation

nonisolated enum AppLanguage: String, CaseIterable {
  case system, english, zhTW

  /// The `@AppStorage` / `UserDefaults` key backing the language preference.
  static let storageKey = "appLanguage"

  var label: String {
    switch self {
    case .system: .appLocalized("System")
    case .english: "English"
    case .zhTW: "繁體中文"
    }
  }

  /// The fixed locale this option pins the app to, or `nil` to follow the device.
  var locale: Locale? {
    switch self {
    case .system: nil
    case .english: Locale(identifier: "en")
    case .zhTW: Locale(identifier: "zh-TW")
    }
  }

  /// The locale this option resolves to, following the device when no locale is pinned.
  var resolvedLocale: Locale {
    locale ?? Locale.autoupdatingCurrent
  }

  /// Reads the stored preference, falling back to `.system` when unset or unrecognized.
  static func stored(in defaults: UserDefaults = .standard) -> AppLanguage {
    guard let rawValue = defaults.string(forKey: storageKey),
      let language = AppLanguage(rawValue: rawValue)
    else { return .system }

    return language
  }

  /// The effective locale for the stored preference, for string construction outside
  /// the SwiftUI environment (model and ViewModel computed properties).
  static func resolvedLocale(from defaults: UserDefaults = .standard) -> Locale {
    stored(in: defaults).resolvedLocale
  }

  /// The bundle holding the localization table for the stored preference.
  ///
  /// `String(localized:locale:)` uses `locale` only for formatting interpolated values —
  /// it does not select a localization table. Non-SwiftUI code therefore has to look the
  /// key up in the matching `.lproj` bundle explicitly. Falls back to `Bundle.main`, whose
  /// lookup returns the English source string.
  static func resolvedBundle(from defaults: UserDefaults = .standard) -> Bundle {
    let identifier = resolvedLocale(from: defaults).identifier
    let preferred = Bundle.preferredLocalizations(
      from: Bundle.main.localizations,
      forPreferences: [identifier]
    )
    guard let localization = preferred.first,
      let path = Bundle.main.path(forResource: localization, ofType: "lproj"),
      let bundle = Bundle(path: path)
    else { return .main }

    return bundle
  }
}
