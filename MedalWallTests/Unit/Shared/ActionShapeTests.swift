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

  @Test("each shape pads itself when the call site passes none")
  func testShapePaddingIsTheDefault() {
    let slab = Self.modifier(shape: .roundedRectangle)
    let hug = Self.modifier(shape: .capsule)

    #expect(slab.resolvedVPadding == 16)
    #expect(slab.resolvedHPadding == 16)
    #expect(hug.resolvedVPadding == 8)
    #expect(hug.resolvedHPadding == 12)
  }

  @Test("a call site padding replaces the shape's own")
  func testCallSitePaddingOverridesTheShape() {
    let inline = Self.modifier(shape: .capsule, vPadding: 0, hPadding: 0)

    #expect(inline.resolvedVPadding == 0)
    #expect(inline.resolvedHPadding == 0)
  }

  @Test("one overridden axis leaves the other on the shape")
  func testEachAxisResolvesOnItsOwn() {
    let tall = Self.modifier(shape: .capsule, vPadding: 20)

    #expect(tall.resolvedVPadding == 20)
    #expect(tall.resolvedHPadding == 12)
  }

  // MARK: - Support
  private static func modifier(
    shape: ActionShape,
    vPadding: CGFloat? = nil,
    hPadding: CGFloat? = nil
  ) -> ActionStyleViewModifier {
    ActionStyleViewModifier(
      style: .primary,
      shape: shape,
      font: .TypeScale.headline,
      vPadding: vPadding,
      hPadding: hPadding
    )
  }
}
