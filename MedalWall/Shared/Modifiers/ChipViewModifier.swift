//
//  ChipViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-08-25.
//

import SwiftUI

/// The appearance of a chip.
///
/// A chip is a capsule that names one thing: a filter the user narrows by, or a
/// hashtag like "#taipei" that labels a medal. A measurement or a status is not a
/// name — those state a fact and take the 6pt rect of a `TagStyle` instead.
///
/// Tappability does not decide the shape here. Filters are tapped and hashtags are
/// not yet, but both stay capsules, so a hashtag becoming tappable later is a change
/// in behaviour rather than a repaint. What does move a label from tag to chip is
/// gaining a remove affordance: a distance you can delete is a chip, the same
/// distance read-only is a tag.
enum ChipStyle {
  case primary
  case secondary
  case neutral

  fileprivate var foreground: Color {
    switch self {
    case .primary: Color.Pigment.paper
    case .secondary: Color.Text.secondary
    case .neutral: Color.Pigment.inkNavy
    }
  }

  fileprivate var background: Color {
    switch self {
    case .primary: Color.Pigment.inkNavy
    case .secondary: Color.Surface.primary
    case .neutral: Color.Surface.tertiary
    }
  }

  fileprivate var border: Color {
    switch self {
    case .primary, .neutral: .clear
    case .secondary: Color.Border.primary
    }
  }
}

/// A view modifier that paints a label as a chip.
struct ChipViewModifier: ViewModifier {
  // MARK: - Environment
  @Environment(\.isEnabled) private var isEnabled

  // MARK: - Properties
  let style: ChipStyle

  // MARK: - Computed
  private var resolvedForeground: Color {
    isEnabled ? style.foreground : Color.Text.secondary
  }

  private var resolvedBackground: Color {
    isEnabled ? style.background : Color.Surface.tertiary
  }

  // MARK: - Body
  func body(content: Content) -> some View {
    content
      .font(.TypeScale.caption)
      .foregroundStyle(resolvedForeground)
      .padding(.vertical, 5)
      .padding(.horizontal, 10)
      .background(resolvedBackground)
      .clipShape(.capsule)
      .overlay(
        Capsule()
          .strokeBorder(isEnabled ? style.border : .clear, lineWidth: 1)
      )
  }
}

extension View {

  /// Applies the design system's chip appearance for `style`.
  func chipStyle(_ style: ChipStyle) -> some View {
    modifier(ChipViewModifier(style: style))
  }
}

#Preview("Filters") {
  HStack(spacing: 8) {
    Text("All").chipStyle(.primary)
    Text("2019").chipStyle(.secondary)
    Text("全馬").chipStyle(.secondary)
    Text("Taipei").chipStyle(.neutral)
  }  // HStack
  .padding()
  .background(Color.Background.primary)
}

#Preview("Hashtags") {
  HStack(spacing: 8) {
    Text("#taipei").chipStyle(.neutral)
    Text("#marathon").chipStyle(.neutral)
    Text("#2026").chipStyle(.neutral)
  }  // HStack
  .padding()
  .background(Color.Surface.primary)
}
