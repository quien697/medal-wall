//
//  Animation+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2026-11-03.
//

import SwiftUI

extension Animation {

  /// The design system's motion tokens.
  struct Motion {
    /// `motion.flip`: a medal turning over to its other face, a 450 ms spring at 0.78 damping.
    static let flip = Animation.spring(response: 0.45, dampingFraction: 0.78)
    /// `motion.flip` under Reduce Motion: the other face fades in over 200 ms.
    static let flipReduced = Animation.easeInOut(duration: 0.2)
  }
}
