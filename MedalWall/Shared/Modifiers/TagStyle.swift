//
//  TagStyle.swift
//  MedalWall
//
//  Created by Quien on 2026-03-12.
//

import SwiftUI

struct TagStyle: ViewModifier {
  let fgColor: Color
  let bgColor: Color
  let vPadding: CGFloat
  let hPadding: CGFloat
  
  func body(content: Content) -> some View {
    content
      .font(.subheadline)
      .fontWeight(.bold)
      .foregroundStyle(fgColor)
      .padding(.vertical, vPadding)
      .padding(.horizontal, hPadding)
      .background(bgColor)
      .clipShape(.capsule)
      .overlay(
        Capsule()
          .stroke(Color.Border.gray, lineWidth: 1)
      )
  }
}

extension View {
  
  func tagStyle(
    fgColor: Color = Color.Text.secondary,
    bgColor: Color = Color.Card.Background.tertiary,
    vPadding: CGFloat = 8,
    hPadding: CGFloat = 12
  ) -> some View {
    modifier(TagStyle(
      fgColor: fgColor,
      bgColor: bgColor,
      vPadding: vPadding,
      hPadding: hPadding
    ))
  }
}

#Preview {
  Text("test data")
    .tagStyle()
}
