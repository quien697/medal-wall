//
//  FieldViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-04-13.
//

import SwiftUI

/// Which side of a form row a piece of text sits on.
///
/// Both sides share one size and are separated by colour: the label names the value in
/// `Text.tertiary`, the value sits opposite in `Text.primary`. Weight is what says the
/// value can be changed, so the value is lighter than its label.
enum FieldStyle {
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

/// A view modifier that sets text as one side of a form row.
struct FieldViewModifier: ViewModifier {
  let style: FieldStyle

  func body(content: Content) -> some View {
    content
      .font(style.font)
      .multilineTextAlignment(style.textAlignment)
      .foregroundStyle(style.foreground)
  }
}

extension View {

  /// Applies the design system's form row text for `style`.
  func fieldStyle(_ style: FieldStyle) -> some View {
    modifier(FieldViewModifier(style: style))
  }
}

#Preview {
  Form {
    LabeledContent {
      TextField("Bib number", text: .constant("00001"))
        .fieldStyle(.value)
    } label: {
      Text("Bib number")
        .fieldStyle(.label)
    }  // LabeledContent
  }  // Form
}
