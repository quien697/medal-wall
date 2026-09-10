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

  @Test("The medal detail's zh-TW strings ship translated")
  func testMedalDetailKeysAreTranslated() {
    let keys = [
      "The result",
      "The day",
      "Location",
      "Date",
      "Distance",
      "Bib",
      "Finish",
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
  @Test("The composed division label keeps its placeholder in zh-TW")
  func testDivisionLabelKeepsPlaceholder() {
    #expect(zhTWTable["Division (%@)"]?.contains("%@") == true)
  }

  @Test("The retired medal list title is gone from the catalog")
  func testRetiredTitleRemoved() {
    #expect(zhTWTable["Your Rewards"] == nil)
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
