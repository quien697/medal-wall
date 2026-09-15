//
//  MedalRingViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-08-28.
//

import SwiftUI

/// The gold ring that marks something earned.
///
/// The ring tracks *earned*, never *photographed* — it is applied by the caller that
/// knows a finish time was recorded, so an image never wears gold on its own. No ring
/// is a real state: it says the result is missing.
///
/// The ring is a circle drawn behind the content, so the content must be circular too.
struct MedalRingViewModifier: ViewModifier {
  private let ringWidth: CGFloat = 3

  func body(content: Content) -> some View {
    content
      .padding(ringWidth)
      .background(Circle().fill(Color.Record.earned))
      .elevation(.ring)
  }
}

extension View {

  /// Wraps the view in the design system's earned gold ring.
  func medalRing() -> some View {
    modifier(MedalRingViewModifier())
  }
}

#Preview {
  VStack(spacing: 40) {
    PhotoImage(photo: UIImage(named: "bmo-vancouver-marathon"), as: .medal)
      .medalRing()

    PhotoImage(photo: nil, as: .medal)
      .medalRing()
  }  // VStack
  .padding(40)
  .background(Color.Background.primary)
}
