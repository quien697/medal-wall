//
//  LocalizationTests.swift
//  MedalWall
//
//  Created by Quien on 2026-08-11.
//

import Foundation
import Testing

@testable import MedalWall

/// Guards the String Catalog infrastructure itself: that a `zh-TW` entry is
/// reachable from plain-Swift code outside the SwiftUI view hierarchy, and that
/// an untranslated key falls back to its English source string.
struct LocalizationTests {

  // MARK: - Support
  private static func makeDefaults(
    appLanguage: String?,
    function: String = #function
  ) -> UserDefaults {
    let suiteName = "LocalizationTests.\(function).\(UUID().uuidString)"
    guard let defaults = UserDefaults(suiteName: suiteName) else {
      fatalError("Unable to create UserDefaults suite")
    }
    defaults.removePersistentDomain(forName: suiteName)
    if let appLanguage {
      defaults.set(appLanguage, forKey: AppLanguage.storageKey)
    }

    return defaults
  }

  // MARK: - Catalog compilation
  @Test("The app bundle ships a zh-TW localization")
  func testZhTWLocalizationIsBundled() {
    #expect(Bundle.main.localizations.contains("zh-TW"))
  }

  // MARK: - resolvedBundle
  @Test("resolvedBundle selects the zh-TW table when Traditional Chinese is stored")
  func testResolvedBundleZhTW() {
    let defaults = Self.makeDefaults(appLanguage: AppLanguage.zhTW.rawValue)
    let bundle = AppLanguage.resolvedBundle(from: defaults)

    #expect(bundle.bundlePath.hasSuffix("zh-TW.lproj"))
  }

  /// Under `.system`, `resolvedBundle` feeds `Locale.autoupdatingCurrent.identifier` in,
  /// which on a real device is region-decorated (`zh-Hant_TW`) rather than the clean
  /// `zh-TW` the catalog is keyed on. If the matcher failed to canonicalize these, a
  /// Taiwanese user on System would silently get English model strings.
  @Test(
    "Device-style Chinese locale identifiers resolve to the zh-TW localization",
    arguments: ["zh-Hant_TW", "zh-Hant-TW", "zh_TW", "zh-TW", "zh-Hant"]
  )
  func testDeviceLocaleIdentifiersResolveToZhTW(identifier: String) {
    let matched = Bundle.preferredLocalizations(
      from: Bundle.main.localizations,
      forPreferences: [identifier]
    ).first

    #expect(matched == "zh-TW")
  }

  @Test("resolvedBundle falls back to the main bundle when English is stored")
  func testResolvedBundleEnglish() {
    let defaults = Self.makeDefaults(appLanguage: AppLanguage.english.rawValue)

    #expect(AppLanguage.resolvedBundle(from: defaults) === Bundle.main)
  }

  // MARK: - String.appLocalized
  @Test("appLocalized resolves a zh-TW catalog entry")
  func testZhTWLookup() {
    let defaults = Self.makeDefaults(appLanguage: AppLanguage.zhTW.rawValue)

    #expect(String.appLocalized("System", defaults: defaults) == "系統")
  }

  @Test("appLocalized resolves the English source string")
  func testEnglishLookup() {
    let defaults = Self.makeDefaults(appLanguage: AppLanguage.english.rawValue)

    #expect(String.appLocalized("System", defaults: defaults) == "System")
  }

  @Test("An untranslated key falls back to its English source string under zh-TW")
  func testUntranslatedKeyFallsBackToEnglish() {
    let defaults = Self.makeDefaults(appLanguage: AppLanguage.zhTW.rawValue)
    let untranslated = String.appLocalized(
      "MedalWall.LocalizationTests.untranslatedKey",
      defaults: defaults
    )

    #expect(untranslated == "MedalWall.LocalizationTests.untranslatedKey")
  }
}
