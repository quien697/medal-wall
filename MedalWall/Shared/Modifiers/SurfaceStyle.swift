//
//  SurfaceStyle.swift
//  MedalWall
//
//  Created by Quien on 2026-03-04.
//

import SwiftUI

struct SurfaceStyle: ViewModifier {
  private let radius: CGFloat = 20
  let background: Color
  let paddingV: CGFloat
  let paddingH: CGFloat
  
  func body(content: Content) -> some View {
    content
      .padding(.vertical, paddingV)
      .padding(.horizontal, paddingH)
      .background(.background)
      .clipShape(.rect(cornerRadius: radius))
      .overlay(
        RoundedRectangle(cornerRadius: radius)
          .stroke(Color.Border.gray, lineWidth: 1)
      )
  }
}
