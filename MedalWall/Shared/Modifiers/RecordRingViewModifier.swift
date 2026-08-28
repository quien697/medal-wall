//
//  RecordRingViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-08-28.
//

import SwiftUI

/// The gold ring that marks something earned.
///
/// The ring tracks *earned*, never *photographed* — it is applied by the caller that
/// knows the record was set, so an image never wears gold on its own.
struct RecordRingViewModifier: ViewModifier {
  private let ringWidth: CGFloat = 3

  func body(content: Content) -> some View {
    content
      .padding(ringWidth)
      .background(Circle().fill(Color.Record.primary))
      .elevation(.ring)
  }
}

extension View {

  /// Wraps the view in the design system's earned gold ring.
  func recordRing() -> some View {
    modifier(RecordRingViewModifier())
  }
}

#Preview {
  VStack(spacing: 40) {
    PhotoImage(photo: UIImage(named: "bmo-vancouver-marathon"), as: .medal)
      .recordRing()

    PhotoImage(photo: nil, as: .medal)
      .recordRing()
  }  // VStack
  .padding(40)
  .background(Color.Background.primary)
}
