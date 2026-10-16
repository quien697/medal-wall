//
//  ProgressBarTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-06.
//

import Foundation
import Testing

@testable import MedalWall

/// Guards the shared progress bar against values outside 0…1, which would give it a negative
/// or overflowing width.
@MainActor
struct ProgressBarTests {

  @Test(
    "the filled share of the track stays within 0 to 1",
    arguments: zip([-0.5, 0, 0.4, 1, 1.7], [0, 0, 0.4, 1, 1])
  )
  func testFilledFractionIsClamped(value: Double, filled: Double) {
    #expect(ProgressBar.filledFraction(value) == filled)
  }

  @Test("a value that isn't a number fills nothing")
  func testNotANumberFillsNothing() {
    #expect(ProgressBar.filledFraction(.nan) == 0)
  }
}
