//
//  SurfaceViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-03-04.
//

import SwiftUI

/// A view modifier that applies a surface appearance
struct SurfaceViewModifier: ViewModifier {
  private let radius: CGFloat = 16
  let bgColor: Color
  let borderColor: Color
  let vPadding: CGFloat
  let hPadding: CGFloat

  func body(content: Content) -> some View {
    content
      .padding(.vertical, vPadding)
      .padding(.horizontal, hPadding)
      .background(bgColor)
      .clipShape(.rect(cornerRadius: radius))
      .overlay(
        RoundedRectangle(cornerRadius: radius)
          .inset(by: 0.5)
          .stroke(borderColor, lineWidth: 1)
      )
  }
}

extension View {

  func surfaceStyle(
    bgColor: Color = Color.Card.Background.primary,
    borderColor: Color? = nil,
    vPadding: CGFloat = 16,
    hPadding: CGFloat = 16
  ) -> some View {
    modifier(
      SurfaceViewModifier(
        bgColor: bgColor,
        borderColor: borderColor ?? Color.Border.gray,
        vPadding: vPadding,
        hPadding: hPadding
      ))
  }
}

#Preview {
  VStack {
    Text("42km")
      .surfaceStyle()
  }
}
