//
//  FromViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-04-13.
//

import SwiftUI

enum FromStyle {
  case label
  case value

  fileprivate var font: Font {
    switch self {
    case .label: .TypeScale.Field.label
    case .value: .TypeScale.Field.value
    }
  }

  fileprivate var textAlignment: TextAlignment {
    switch self {
    case .label: .leading
    case .value: .trailing
    }
  }

  fileprivate var foreground: Color {
    switch self {
    case .label: Color.Text.tertiary
    case .value: Color.Text.primary
    }
  }
}

struct FromViewModifier: ViewModifier {
  let style: FromStyle

  func body(content: Content) -> some View {
    content
      .font(style.font)
      .multilineTextAlignment(style.textAlignment)
      .foregroundStyle(style.foreground)
  }
}

extension View {

  func fromStyle(_ style: FromStyle) -> some View {
    modifier(FromViewModifier(style: style))
  }
}

#Preview {
  let text: String = ""

  Form {
    LabeledContent {
      TextField("Text", text: .constant(text))
        .fromStyle(.value)
    } label: {
      Text("Text Title")
        .fromStyle(.label)
    }
  }
}
