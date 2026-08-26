//
//  TierBadgeTests.swift
//  MedalWall
//
//  Created by Quien on 2026-08-26.
//

import CoreGraphics
import Testing

@testable import MedalWall

struct TierBadgeTests {

  @Test("numeral keeps its full size up to two digits")
  func testNumeralFontSizeForShortThresholds() {
    #expect(TierBadge.numeralFontSize(forThreshold: 1) == 17)
    #expect(TierBadge.numeralFontSize(forThreshold: 10) == 17)
    #expect(TierBadge.numeralFontSize(forThreshold: 50) == 17)
  }

  @Test("numeral drops one notch from three digits on")
  func testNumeralFontSizeForLongThresholds() {
    #expect(TierBadge.numeralFontSize(forThreshold: 100) == 15)
    #expect(TierBadge.numeralFontSize(forThreshold: 999) == 15)
    #expect(TierBadge.numeralFontSize(forThreshold: 1_000) == 15)
  }

  @Test("a negative threshold clamps to the full size instead of counting its sign")
  func testNumeralFontSizeForNegativeThreshold() {
    #expect(TierBadge.numeralFontSize(forThreshold: -100) == 17)
  }

  @Test("every shipped tier resolves a positive size")
  func testNumeralFontSizeForEveryTier() {
    for tier in AchievementTier.allCases {
      #expect(TierBadge.numeralFontSize(forThreshold: tier.threshold) > 0)
    }
  }
}
