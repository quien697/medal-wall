//
//  TagViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-08-25.
//

import SwiftUI

/// What a tag says about a medal.
///
/// A tag states a fact and is never tappable, so it takes the small rect rather
/// than a capsule — the shape is what separates it from a `FilterChipStyle`.
/// `record` is champagne and reserved for a personal record; distance and race
/// type are facts rather than achievements, so they stay `neutral`.
enum TagStyle {
  case record
  case neutral
  case success
  case error

  fileprivate var foreground: Color {
    switch self {
    case .record: Color.Record.ink
    case .neutral: Color.Text.secondary
    case .success: Color.Status.success
    case .error: Color.Status.error
    }
  }

  /// Status tags drop their tinted fill in dark and share `cardInset`,
  /// carrying the status in the text only — the light tints go muddy there.
  fileprivate var background: Color {
    switch self {
    case .record: Color.Record.champagne
    case .neutral: Color.Surface.tertiary
    case .success: Color.Status.success.opacity(0.2)
    case .error: Color.Status.error.opacity(0.2)
    }
  }
}

/// A view modifier that paints a label as a tag.
struct TagViewModifier: ViewModifier {
  let style: TagStyle
  let font: Font
  let vPadding: CGFloat
  let hPadding: CGFloat

  func body(content: Content) -> some View {
    content
      .font(font)
      .tracking(1)
      .foregroundStyle(style.foreground)
      .padding(.vertical, vPadding)
      .padding(.horizontal, hPadding)
      .background(style.background)
      .clipShape(.rect(cornerRadius: .Radius.tag))
  }
}

extension View {

  /// Applies the design system's tag appearance for `style`.
  func tagStyle(
    _ style: TagStyle,
    font: Font = .TypeScale.label,
    vPadding: CGFloat = 5,
    hPadding: CGFloat = 9
  ) -> some View {
    modifier(
      TagViewModifier(
        style: style,
        font: font,
        vPadding: vPadding,
        hPadding: hPadding)
    )
  }
}

#Preview("Default") {
  HStack(spacing: 8) {
    Text("PR").tagStyle(.record)
    Text("Full").tagStyle(.neutral)
    Text("16.1 km").tagStyle(.neutral)
    Text("Synced").tagStyle(.success)
    Text("Draft").tagStyle(.error)
  }  // HStack
  .padding()
  .background(Color.Background.primary)
}

#Preview("Custom") {
  HStack(spacing: 8) {
    Text("Full").tagStyle(.neutral, font: .TypeScale.callout)
    Text("16.1 km").tagStyle(.neutral)
  }  // HStack
  .padding()
  .background(Color.Background.primary)
}
