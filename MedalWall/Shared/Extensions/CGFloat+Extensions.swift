//
//  CGFloat+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2026-08-25.
//

import SwiftUI

extension CGFloat {

  /// The design system's corner radii, named by the role they belong to.
  ///
  /// The pill radius is deliberately absent — SwiftUI expresses it natively as
  /// `.capsule`, which stays correct at any height.
  struct Radius {
    static let tag: CGFloat = 6
    static let field: CGFloat = 12
    static let button: CGFloat = 14
    static let image: CGFloat = 14
    static let surface: CGFloat = 18
    static let sheet: CGFloat = 20
  }

  /// The design system's space scale, named by what the gap separates.
  ///
  /// Six steps and no more: anything above `section` is a layout decision rather
  /// than a token. A step is passed even where it lands on the number SwiftUI
  /// would have chosen anyway — the implicit `VStack` gap is roughly `stack` and
  /// a screen edge is roughly `gutter`, but neither is a decision until it is written.
  struct Space {
    static let inline: CGFloat = 4
    static let stack: CGFloat = 8
    static let row: CGFloat = 12
    static let gutter: CGFloat = 16
    static let panel: CGFloat = 20
    static let section: CGFloat = 24
  }
}
