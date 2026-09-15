//
//  SectionTitleViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-03-06.
//

import SwiftUI

/// A view modifier that sets a label as a section heading.
///
/// There is no section-title type step, on purpose: a heading is `callout` turned
/// heavy, uppercased and tracked +1pt, in `Text.secondary`. Case and colour already
/// separate it from a `Field.label` above it and an `overline` beside it, and a step
/// that only ever appeared through this modifier would drift from it the first time
/// either changed.
struct SectionTitleViewModifier: ViewModifier {

  func body(content: Content) -> some View {
    content
      .font(.TypeScale.callout)
      .fontWeight(.heavy)
      .textCase(.uppercase)
      .tracking(1)
      .foregroundStyle(Color.Text.secondary)
  }
}

extension View {

  /// Applies the design system's section heading.
  func sectionTitleStyle() -> some View {
    modifier(SectionTitleViewModifier())
  }
}

#Preview {
  Text("Achievements")
    .sectionTitleStyle()
    .padding()
    .background(Color.Background.primary)
}
