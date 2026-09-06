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
/// than a capsule — the shape is what separates it from a `ChipStyle`.
/// `record` is champagne and reserved for a personal record; distance and race
/// type are facts rather than achievements, so they stay neutral.
///
/// The two neutral cases differ only in what sits behind them: a fill is picked by
/// its ground, so a tag inside a card or section recesses with `Surface.tertiary`
/// while one sitting on the page needs the darker `Surface.quaternary` to stay visible.
///
/// The variants also read differently: a badge is scanned by shape and colour, so it
/// is short and uppercase; a neutral tag is content you actually read, so it keeps
/// sentence case at a legible size.
enum TagStyle {
  case record
  case neutralInCard
  case neutralOnPage
  case success
  case error

  fileprivate var foreground: Color {
    switch self {
    case .record: Color.Record.ink
    case .neutralInCard, .neutralOnPage: Color.Text.secondary
    case .success: Color.Status.success
    case .error: Color.Status.error
    }
  }

  fileprivate var background: Color {
    switch self {
    case .record: Color.Record.champagne
    case .neutralInCard: Color.Surface.tertiary
    case .neutralOnPage: Color.Surface.quaternary
    case .success: Color.Status.success.opacity(0.2)
    case .error: Color.Status.error.opacity(0.2)
    }
  }

  fileprivate var font: Font {
    switch self {
    case .neutralInCard, .neutralOnPage: Font.TypeScale.caption
    case .record, .success, .error: Font.TypeScale.overline
    }
  }

  fileprivate var textCase: Text.Case? {
    switch self {
    case .neutralInCard, .neutralOnPage: nil
    case .record, .success, .error: .uppercase
    }
  }
}

/// A view modifier that paints a label as a tag.
struct TagViewModifier: ViewModifier {
  let style: TagStyle
  let font: Font?
  let vPadding: CGFloat
  let hPadding: CGFloat

  func body(content: Content) -> some View {
    content
      .font(font ?? style.font)
      .textCase(style.textCase)
      .foregroundStyle(style.foreground)
      .padding(.vertical, vPadding)
      .padding(.horizontal, hPadding)
      .background(style.background)
      .clipShape(.rect(cornerRadius: .Radius.tag))
  }
}

extension View {

  /// Applies the design system's tag appearance for `style`.
  ///
  /// Every argument past `style` overrides what the style already carries — pass one
  /// only where a call site genuinely departs from the design system.
  func tagStyle(
    _ style: TagStyle,
    font: Font? = nil,
    vPadding: CGFloat = 4,
    hPadding: CGFloat = 8
  ) -> some View {
    modifier(
      TagViewModifier(
        style: style,
        font: font,
        vPadding: vPadding,
        hPadding: hPadding
      )
    )
  }
}

#Preview("On a card") {
  VStack(spacing: 8) {
    Text("PR").tagStyle(.record)
    Text("Full").tagStyle(.neutralInCard)
    Text("42.195 km").tagStyle(.neutralInCard)
    Text("Synced").tagStyle(.success)
    Text("Draft").tagStyle(.error)
  }  // VStack
  .padding()
  .surfaceStyle()
  .padding()
  .background(Color.Background.primary)
}

#Preview("On the page") {
  VStack(spacing: 8) {
    Text("Full").tagStyle(.neutralOnPage)
    Text("In-person").tagStyle(.neutralOnPage)
    Text("42.195 km").tagStyle(.neutralOnPage)
    Text("全馬").tagStyle(.neutralOnPage)
  }  // VStack
  .padding()
  .background(Color.Background.primary)
}
