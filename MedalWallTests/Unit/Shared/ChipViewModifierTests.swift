//
//  ChipViewModifierTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-06.
//

import SwiftUI
import Testing

@testable import MedalWall

@MainActor
struct ChipViewModifierTests {

  // MARK: - Support
  private func modifier(font: Font? = nil) -> ChipViewModifier {
    ChipViewModifier(style: .primary, font: font, vPadding: 5, hPadding: 10)
  }

  // MARK: - Tests
  @Test("a chip left alone reads at caption, the step a filter shares with a meta tag")
  func testDefaultFontIsCaption() {
    #expect(modifier().resolvedFont == Font.TypeScale.caption)
  }

  @Test("a call site font replaces the default rather than being dropped")
  func testCallSiteFontOverridesTheDefault() {
    #expect(modifier(font: .TypeScale.overline).resolvedFont == Font.TypeScale.overline)
  }
}
