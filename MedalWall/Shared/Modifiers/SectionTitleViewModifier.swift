//
//  SectionTitleViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-03-06.
//

import SwiftUI

struct SectionTitleViewModifier: ViewModifier {

  func body(content: Content) -> some View {
    content
      .font(.headline)
      .fontWeight(.heavy)
      .textCase(.uppercase)
      .foregroundStyle(Color.Text.tertiary)
  }
}

extension View {

  func sectionTitleStyle() -> some View {
    modifier(SectionTitleViewModifier())
  }
}

#Preview {
  Text("Achievements")
    .sectionTitleStyle()
}
