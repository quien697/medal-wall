//
//  CardModifier.swift
//  MedalWall
//
//  Created by Quien on 2025-11-01.
//

import SwiftUI

struct CardStyleModifier: ViewModifier {
  let paddingH: CGFloat
  let paddingV: CGFloat
  let marginH: CGFloat
  let marginV: CGFloat
  let cornerRadius: CGFloat
  
  func body(content: Content) -> some View {
    content
      .padding(.horizontal, paddingH)
      .padding(.vertical, paddingV)
      .background(.background)
      .clipShape(.rect(cornerRadius: cornerRadius))
      .shadow(color: .black.opacity(0.2), radius: 4)
      .padding(.horizontal, marginH)
      .padding(.vertical, marginV)
  }
}

extension View {
  func cardStyle(
    paddingH : CGFloat = 20,
    paddingV : CGFloat = 20,
    marginH : CGFloat = 10,
    marginV : CGFloat = 5,
    cornerRadius : CGFloat = 20,
  ) -> some View {
    modifier(CardStyleModifier(
      paddingH: paddingH,
      paddingV: paddingV,
      marginH: marginH,
      marginV: marginV,
      cornerRadius: cornerRadius)
    )
  }
}
