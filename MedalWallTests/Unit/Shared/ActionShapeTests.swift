//
//  ActionShapeTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-02.
//

import CoreGraphics
import SwiftUI
import Testing

@testable import MedalWall

@MainActor
struct ActionShapeTests {

  /// A slab-sized action, wide enough that a capsule and a 14pt corner differ.
  private static let bounds = CGRect(x: 0, y: 0, width: 200, height: 52)

  @Test("the rounded rectangle cuts its corner at the button radius")
  func testRoundedRectangleUsesButtonRadius() {
    let fill = ActionShape.roundedRectangle.clipShape.path(in: Self.bounds)

    #expect(fill.contains(CGPoint(x: 2, y: 2)) == false)  // not a square corner
    #expect(fill.contains(CGPoint(x: 3, y: 8)))  // not a capsule
  }

  @Test("the capsule carries its corner to half the height")
  func testCapsuleUsesHalfHeightRadius() {
    let fill = ActionShape.capsule.clipShape.path(in: Self.bounds)

    #expect(fill.contains(CGPoint(x: 3, y: 8)) == false)  // not a 14pt corner
    #expect(fill.contains(CGPoint(x: 100, y: 26)))  // centre still filled
  }
}
