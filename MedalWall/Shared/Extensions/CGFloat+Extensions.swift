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
}
