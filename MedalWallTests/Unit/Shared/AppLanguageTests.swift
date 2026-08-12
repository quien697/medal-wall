//
//  AppLanguageTests.swift
//  MedalWall
//
//  Created by Quien on 2026-08-11.
//

import Foundation
import Testing

@testable import MedalWall

struct AppLanguageTests {

  // MARK: - Support
  /// A throwaway `UserDefaults` suite so tests never mutate `.standard`.
  private static func makeDefaults(
    appLanguage: String?,
    function: String = #function
  ) -> UserDefaults {
    let suiteName = "AppLanguageTests.\(function).\(UUID().uuidString)"
    guard let defaults = UserDefaults(suiteName: suiteName) else {
      fatalError("Unable to create UserDefaults suite")
    }
    defaults.removePersistentDomain(forName: suiteName)
    if let appLanguage {
      defaults.set(appLanguage, forKey: AppLanguage.storageKey)
    }

    return defaults
  }

  // MARK: - label
  @Test("System label")
  func testSystemLabel() {
    #expect(AppLanguage.system.label == "System")
  }

  @Test("English label is the endonym and is not translated")
  func testEnglishLabel() {
    #expect(AppLanguage.english.label == "English")
  }

  @Test("Traditional Chinese label is the endonym and is not translated")
  func testZhTWLabel() {
    #expect(AppLanguage.zhTW.label == "繁體中文")
  }

  // MARK: - locale
  @Test("System resolves to no fixed locale")
  func testSystemLocale() {
    #expect(AppLanguage.system.locale == nil)
  }

  @Test("English resolves to the en locale")
  func testEnglishLocale() {
    #expect(AppLanguage.english.locale == Locale(identifier: "en"))
  }

  @Test("Traditional Chinese resolves to the zh-TW locale")
  func testZhTWLocale() {
    #expect(AppLanguage.zhTW.locale == Locale(identifier: "zh-TW"))
  }

  // MARK: - resolvedLocale
  @Test("resolvedLocale returns en when English is stored")
  func testResolvedLocaleEnglish() {
    let defaults = Self.makeDefaults(appLanguage: AppLanguage.english.rawValue)

    #expect(AppLanguage.resolvedLocale(from: defaults) == Locale(identifier: "en"))
  }

  @Test("resolvedLocale returns zh-TW when Traditional Chinese is stored")
  func testResolvedLocaleZhTW() {
    let defaults = Self.makeDefaults(appLanguage: AppLanguage.zhTW.rawValue)

    #expect(AppLanguage.resolvedLocale(from: defaults) == Locale(identifier: "zh-TW"))
  }

  @Test("resolvedLocale falls back to the device locale when System is stored")
  func testResolvedLocaleSystem() {
    let defaults = Self.makeDefaults(appLanguage: AppLanguage.system.rawValue)

    #expect(AppLanguage.resolvedLocale(from: defaults) == Locale.autoupdatingCurrent)
  }

  @Test("resolvedLocale falls back to the device locale when nothing is stored")
  func testResolvedLocaleUnset() {
    let defaults = Self.makeDefaults(appLanguage: nil)

    #expect(AppLanguage.resolvedLocale(from: defaults) == Locale.autoupdatingCurrent)
  }

  @Test("resolvedLocale falls back to the device locale for an unrecognized stored value")
  func testResolvedLocaleUnrecognized() {
    let defaults = Self.makeDefaults(appLanguage: "klingon")

    #expect(AppLanguage.resolvedLocale(from: defaults) == Locale.autoupdatingCurrent)
  }

  // MARK: - stored
  @Test("stored reads the persisted preference")
  func testStored() {
    let defaults = Self.makeDefaults(appLanguage: AppLanguage.zhTW.rawValue)

    #expect(AppLanguage.stored(in: defaults) == .zhTW)
  }

  @Test("stored defaults to system when nothing is persisted")
  func testStoredUnset() {
    let defaults = Self.makeDefaults(appLanguage: nil)

    #expect(AppLanguage.stored(in: defaults) == .system)
  }
}
