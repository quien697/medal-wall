//
//  IconStyleModifier.swift
//  MedalWall
//
//  Created by Quien on 2025-11-07.
//

import SwiftUI

struct IconStyleModifier: ViewModifier {
  var color: Color = .primary
  var font: Font = .default
  var padding: CGFloat = 0
  
  func body(content: Content) -> some View {
    content
      .font(font)
      .foregroundStyle(color)
      .padding(padding)
  }
}

extension IconStyleModifier {
  static var cardListIcon: IconStyleModifier {
    IconStyleModifier(
      color: .secondary,
      font: .subheadline,
      padding: 0
    )
  }
}
