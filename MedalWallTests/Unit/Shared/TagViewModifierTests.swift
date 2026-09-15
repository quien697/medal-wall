//
//  TagViewModifierTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-15.
//

import SwiftUI
import Testing

@testable import MedalWall

@MainActor
struct TagViewModifierTests {

  // MARK: - Support
  private func modifier(_ style: TagStyle) -> TagViewModifier {
    TagViewModifier(style: style, font: nil, textCase: nil, vPadding: 4, hPadding: 8)
  }

  // MARK: - Tests
  @Test(
    "a badge tracks its uppercase label out",
    arguments: [TagStyle.record, .success, .error]
  )
  func testBadgeIsTracked(style: TagStyle) {
    #expect(modifier(style).resolvedTracking == 0.6)
  }

  @Test(
    "a meta tag is read as sentence case, so it keeps the step's own spacing",
    arguments: [TagStyle.neutralInCard, .neutralOnPage]
  )
  func testMetaTagIsNotTracked(style: TagStyle) {
    #expect(modifier(style).resolvedTracking == 0)
  }
}
