//
//  FromLabelViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-04-13.
//

import SwiftUI

struct FromLabelViewModifier: ViewModifier {

  func body(content: Content) -> some View {
    content
      .font(.TypeScale.Field.label)
      .foregroundStyle(Color.Text.tertiary)
  }
}

extension View {

  func fromLabelStyle() -> some View {
    modifier(FromLabelViewModifier())
  }
}

#Preview {
  let text: String = ""

  Form {
    LabeledContent {
      TextField("Text", text: .constant(text))
    } label: {
      Text("Text Title")
        .fromLabelStyle()
    }
  }
}
