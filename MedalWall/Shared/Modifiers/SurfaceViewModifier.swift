//
//  SurfaceViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-03-04.
//

import SwiftUI

/// A view modifier that sets content on the design system's surface: a medal card,
/// list row, or stat card.
///
/// The surface is separated from the page by `elevation.hairline` — a 1pt
/// `Border.primary` stroke and no shadow. The stroke is drawn inside the shape, so the
/// border never adds to the card's size.
struct SurfaceViewModifier: ViewModifier {
  let bgColor: Color
  let borderColor: Color
  let vPadding: CGFloat
  let hPadding: CGFloat

  func body(content: Content) -> some View {
    content
      .padding(.vertical, vPadding)
      .padding(.horizontal, hPadding)
      .background(bgColor)
      .clipShape(.rect(cornerRadius: .Radius.surface))
      .overlay(
        RoundedRectangle(cornerRadius: .Radius.surface)
          .strokeBorder(borderColor, lineWidth: 1)
      )
  }
}

extension View {

  /// Applies the design system's surface: a card at `Radius.surface`, padded by
  /// `Space.gutter`.
  ///
  /// Every argument overrides what the surface already carries — pass one only where a
  /// call site genuinely departs from the design system.
  func surfaceStyle(
    bgColor: Color = Color.Surface.primary,
    borderColor: Color = Color.Border.primary,
    vPadding: CGFloat = .Space.gutter,
    hPadding: CGFloat = .Space.gutter
  ) -> some View {
    modifier(
      SurfaceViewModifier(
        bgColor: bgColor,
        borderColor: borderColor,
        vPadding: vPadding,
        hPadding: hPadding
      )
    )
  }
}

#Preview {
  VStack(spacing: .Space.row) {
    Text("The weather was good, not too much up hill and down hill.")
      .font(.TypeScale.body)
      .foregroundStyle(Color.Text.primary)
      .frame(maxWidth: .infinity, alignment: .leading)
      .surfaceStyle()

    Text("Compact")
      .font(.TypeScale.body)
      .foregroundStyle(Color.Text.primary)
      .frame(maxWidth: .infinity, alignment: .leading)
      .surfaceStyle(vPadding: .Space.row, hPadding: .Space.row)
  }  // VStack
  .padding()
  .background(Color.Background.primary)
}
