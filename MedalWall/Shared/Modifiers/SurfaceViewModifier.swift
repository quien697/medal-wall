//
//  SurfaceViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-03-04.
//

import SwiftUI

struct SurfaceViewModifier: ViewModifier {
  private let radius: CGFloat = 20
  let bgColor: Color
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
          .stroke(Color.Border.gray, lineWidth: 1)
      )
  }
}

extension View {
  
  func surfaceStyle(
    bgColor: Color = Color.Card.Background.primary,
    vPadding: CGFloat = 15,
    hPadding: CGFloat = 15
  ) -> some View {
    modifier(SurfaceViewModifier(
      bgColor: bgColor,
      vPadding: vPadding,
      hPadding: hPadding
    ))
  }
}

#Preview {
  VStack{
    Text("42km")
  }
  .surfaceStyle()
}
