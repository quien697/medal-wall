//
//  TextStyleModifier.swift
//  MedalWall
//
//  Created by Quien on 2025-11-07.
//

import SwiftUI

struct TextStyleModifier: ViewModifier {
  var color: Color = .primary
  var font: Font = .default
  var weight: Font.Weight = .regular
  
  func body(content: Content) -> some View {
    content
      .font(font)
      .fontWeight(weight)
      .foregroundColor(color)
  }
}

extension View {
  func cardTextStyle(
    color: Color = .primary,
    font: Font = .default,
    weight: Font.Weight = .regular
  ) -> some View {
    modifier(TextStyleModifier(color: color, font: font, weight: weight))
  }
}

extension TextStyleModifier {
  enum Card {
    static var title: TextStyleModifier {
      TextStyleModifier(color: .primary, font: .headline)
    }
    
    static var listText: TextStyleModifier {
      TextStyleModifier(color: .primary, font: .subheadline)
    }
    
    static var listLink: TextStyleModifier {
      TextStyleModifier(color: .blue, font: .subheadline)
    }
  }
}
