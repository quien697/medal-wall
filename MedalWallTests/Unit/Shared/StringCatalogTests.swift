//
//  StringCatalogTests.swift
//  MedalWall
//
//  Created by Quien on 2026-08-11.
//

import Foundation
import Testing

@testable import MedalWall

/// Guards the compiled `zh-TW` table shipped inside the app bundle.
struct StringCatalogTests {

  // MARK: - Support
  private var zhTWTable: [String: String] {
    let defaults = UserDefaults(suiteName: "StringCatalogTests")
    defaults?.set(AppLanguage.zhTW.rawValue, forKey: AppLanguage.storageKey)
    let bundle = AppLanguage.resolvedBundle(from: defaults ?? .standard)
    guard let path = bundle.path(forResource: "Localizable", ofType: "strings"),
      let table = NSDictionary(contentsOfFile: path) as? [String: String]
    else { return [:] }

    return table
  }

  // MARK: - Tests
  @Test("The compiled zh-TW table ships with the app")
  func testTableIsBundled() {
    #expect(zhTWTable.count > 200)
  }

  @Test("No zh-TW entry is empty")
  func testNoEmptyTranslations() {
    for (key, value) in zhTWTable {
      let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)

      #expect(!trimmed.isEmpty, "empty value for \(key)")
    }
  }

  @Test("The medal list's zh-TW strings ship translated")
  func testMedalListKeysAreTranslated() {
    let keys = [
      "Your Collection",
      "All",
      "No time recorded",
      "PR",
      "Personal best",
      "^[%lld medal](inflect: true)"
    ]

    for key in keys {
      #expect(zhTWTable[key] != nil, "missing zh-TW entry for \(key)")
    }
  }

  @Test("The race list's zh-TW strings ship translated")
  func testRaceListKeysAreTranslated() {
    let keys = [
      "No Race Events",
      "^[%lld edition](inflect: true)"
    ]

    for key in keys {
      #expect(zhTWTable[key] != nil, "missing zh-TW entry for \(key)")
    }
  }

  @Test("The Search tab's zh-TW strings ship translated")
  func testSearchKeysAreTranslated() {
    let keys = [
      "Search",
      "Search Races and Medals",
      "Find any race by name, city or country.",
      "Search races and medals",
      "Your Collection",
      "Races"
    ]

    for key in keys {
      #expect(zhTWTable[key] != nil, "missing zh-TW entry for \(key)")
    }
  }

  @Test("The medal detail's zh-TW strings ship translated")
  func testMedalDetailKeysAreTranslated() {
    let keys = [
      "The result",
      "The day",
      "Location",
      "Date",
      "Distance",
      "Bib",
      "Avg pace",
      "Overall",
      "Gender",
      "Division",
      "Division (%@)"
    ]

    for key in keys {
      #expect(zhTWTable[key] != nil, "missing zh-TW entry for \(key)")
    }
  }

  /// The division label is composed, so the translation must keep its placeholder or the
  /// group silently vanishes from the label.
  @Test("The launch screen's zh-TW strings ship translated")
  func testLaunchKeysAreTranslated() {
    #expect(zhTWTable["Loading your collection"] != nil)
  }

  @Test("The email sign-in link errors' zh-TW strings ship translated")
  func testEmailLinkErrorKeysAreTranslated() {
    let keys = [
      "We couldn't sign you in with this link.",
      "This sign-in link wasn't requested on this device.",
      "Please check your connection, or request a new link.",
      "Please request a new link on this device."
    ]

    for key in keys {
      #expect(zhTWTable[key] != nil, "missing zh-TW entry for \(key)")
    }
  }

  /// The footer names the units as zh-TW shows them, 公里 and 英里, not km and mi.
  @Test("The distance entry and Settings zh-TW strings ship translated")
  func testDistanceEntryAndSettingsKeysAreTranslated() {
    #expect(zhTWTable["Custom distance"] == "自訂距離")
    #expect(zhTWTable["Unit"] == "單位")
    #expect(
      zhTWTable[
        "Distance sets the pace unit (/km or /mi) and the starting unit for a custom distance. "
          + "Distances always show as they were entered."
      ] == "「距離」設定配速單位（/公里 或 /英里）及自訂距離的預設單位。距離一律依輸入時的單位顯示。")
  }

  @Test("The label VoiceOver reads for a skeleton ships translated")
  func testSkeletonLabelIsTranslated() {
    #expect(zhTWTable["Loading"] == "載入中")
  }

  @Test("The You tab's empty state ships translated")
  func testProfileUnavailableIsTranslated() {
    #expect(zhTWTable["Profile Unavailable"] == "個人資料無法使用")
    #expect(
      zhTWTable["We couldn't load your profile. Please check your connection and try again."]
        == "我們無法載入你的個人資料。請檢查網路連線後再試一次。")
  }

  @Test("The composed division label keeps its placeholder in zh-TW")
  func testDivisionLabelKeepsPlaceholder() {
    #expect(zhTWTable["Division (%@)"]?.contains("%@") == true)
  }

  @Test("The retired medal list title is gone from the catalog")
  func testRetiredTitleRemoved() {
    #expect(zhTWTable["Your Rewards"] == nil)
  }

  @Test("The retired distance strings are gone from the catalog")
  func testRetiredDistanceStringsRemoved() {
    #expect(zhTWTable["Custom distance (%@)"] == nil)
    #expect(zhTWTable["Distance must be greater than zero."] == nil)
    #expect(zhTWTable["Please enter a distance greater than 0."] == nil)
    #expect(zhTWTable["Distance must be greater than zero, with at most 4 decimal places."] == nil)
    #expect(
      zhTWTable["Please enter a distance greater than 0, with up to 4 decimal places."] == nil)
  }

  @Test("The Races list's retired search strings are gone from the catalog")
  func testRetiredRaceSearchStringsRemoved() {
    #expect(zhTWTable["Search race events..."] == nil)
    #expect(zhTWTable["No race events match '%@'"] == nil)
    #expect(zhTWTable["No Results"] == nil)
  }

  @Test("Every zh-TW entry keeps the format specifiers of its key")
  func testFormatSpecifiersArePreserved() {
    for (key, value) in zhTWTable {
      let keySpecifiers = key.formatSpecifierCount
      #expect(
        value.formatSpecifierCount == keySpecifiers,
        "specifier mismatch for \(key) -> \(value)"
      )
    }
  }
}

extension String {
  /// Number of `%@` / `%lld` style placeholders, used to compare a key with its translation.
  fileprivate var formatSpecifierCount: Int {
    ranges(of: /%(?:@|lld|d|lf|f)/).count
  }
}
