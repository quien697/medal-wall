//
//  SkeletonViewModifierTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-19.
//

import SwiftUI
import Testing

@testable import MedalWall

@MainActor
struct SkeletonViewModifierTests {

  @Test("a bone on the page takes skeleton.onPage")
  func testPageBoneColor() {
    #expect(SkeletonSurface.page.boneColor == Color.Skeleton.onPage)
  }

  @Test("a bone inside a card takes skeleton.inCard, so it shows against the card's fill")
  func testCardBoneColor() {
    #expect(SkeletonSurface.card.boneColor == Color.Skeleton.inCard)
  }

  // MARK: - Bars
  @Test("a bar sits centred in its content's frame at its own height, at full width")
  func testBarBoneIsCentredAtItsHeight() {
    let line = CGRect(x: 0, y: 0, width: 120, height: 22)
    let bar = BarBone(height: 16, cornerRadius: 6).path(in: line)

    #expect(bar.contains(CGPoint(x: 60, y: 2)) == false)  // gap above: the bar starts at 3
    #expect(bar.contains(CGPoint(x: 60, y: 4)))
    #expect(bar.contains(CGPoint(x: 60, y: 18)))
    #expect(bar.contains(CGPoint(x: 60, y: 20)) == false)  // gap below: the bar ends at 19
    #expect(bar.boundingRect.width == 120)  // the content's full width
  }

  @Test("a bar never grows past its content's frame, so it cannot cover a neighbour")
  func testBarBoneFitsItsFrame() {
    let shrunkLine = CGRect(x: 0, y: 0, width: 40, height: 12)
    let bar = BarBone(height: 30, cornerRadius: 6).path(in: shrunkLine)

    #expect(bar.boundingRect.height == 12)
  }

  @Test("a tag's bar and a chip's are one height, so a row of them lines up")
  func testTagAndChipBarsMatch() {
    #expect(BoneSize.tag.height == BoneSize.chip.height)
  }

  @Test("a chip's bar is a capsule, as the chip is")
  func testChipBarIsCapsule() {
    #expect(BoneSize.chip.cornerRadius == BoneSize.chip.height / 2)
  }

  // MARK: - Opacity
  @Test("an inactive skeleton leaves its content fully shown")
  func testInactiveSkeletonIsOpaque() {
    let opacity = SkeletonViewModifier.opacity(
      isActive: false, secondsSinceReveal: 0.5, isReduceMotionOn: false)

    #expect(opacity == 1)
  }

  @Test("bones stay hidden until they are revealed, so a quick load never flashes them")
  func testBonesHiddenBeforeReveal() {
    let opacity = SkeletonViewModifier.opacity(
      isActive: true, secondsSinceReveal: nil, isReduceMotionOn: false)

    #expect(opacity == 0)
  }

  @Test("revealed bones pulse from 0.6 up to 1 over 1.2 s and back")
  func testBonesPulse() {
    let start = SkeletonViewModifier.opacity(
      isActive: true, secondsSinceReveal: 0, isReduceMotionOn: false)
    let peak = SkeletonViewModifier.opacity(
      isActive: true, secondsSinceReveal: 1.2, isReduceMotionOn: false)
    let back = SkeletonViewModifier.opacity(
      isActive: true, secondsSinceReveal: 2.4, isReduceMotionOn: false)

    #expect(start == 0.6)
    #expect(peak == 1)
    #expect(back == 0.6)
  }

  @Test("under Reduce Motion revealed bones hold still at full opacity", arguments: [0, 0.6, 1.8])
  func testReduceMotionHoldsStill(secondsSinceReveal: Double) {
    let opacity = SkeletonViewModifier.opacity(
      isActive: true, secondsSinceReveal: secondsSinceReveal, isReduceMotionOn: true)

    #expect(opacity == 1)
  }

  @Test("a frame timed just before the reveal reads as the start of the pulse")
  func testFrameBeforeRevealReadsAsStart() {
    let opacity = SkeletonViewModifier.opacity(
      isActive: true, secondsSinceReveal: -0.01, isReduceMotionOn: false)

    #expect(opacity == 0.6)
  }
}
