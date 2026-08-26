//
//  ActionStyleViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-08-25.
//

import SwiftUI

/// The priority of a button, which decides its colours and padding.
///
/// Pressed and disabled are states rather than styles — they apply on top of
/// any case, so neither gets one of its own.
enum ActionStyle {
  case primary
  case secondary
  case tertiary
  case plain
  case destructive

  fileprivate var foreground: Color {
    switch self {
    case .primary: Color.Background.primary
    case .secondary, .tertiary, .plain: Color.Pigment.inkNavy
    case .destructive: Color.Status.error
    }
  }

  fileprivate var background: Color {
    switch self {
    case .primary: Color.Pigment.inkNavy
    case .secondary, .tertiary: Color.Surface.primary
    case .plain, .destructive: .clear
    }
  }

  fileprivate var border: Color {
    switch self {
    case .primary, .plain: .clear
    case .secondary: Color.Pigment.inkNavy
    case .tertiary: Color.Border.primary
    case .destructive: Color.Status.error
    }
  }

  fileprivate var borderWidth: CGFloat {
    switch self {
    case .primary, .plain: 0
    case .secondary, .destructive: 1.5
    case .tertiary: 1
    }
  }

  /// Padding absorbs the border width so every style lands on the same height.
  fileprivate var vPadding: CGFloat {
    switch self {
    case .primary: 14
    case .secondary, .tertiary, .destructive: 13
    case .plain: 12
    }
  }
}

/// A view modifier that paints a label as a button.
struct ActionStyleViewModifier: ViewModifier {

  // MARK: - Environment
  @Environment(\.isEnabled) private var isEnabled

  // MARK: - Properties
  let style: ActionStyle
  let font: Font
  let fontWeight: Font.Weight
  let vPadding: CGFloat?
  let hPadding: CGFloat

  // MARK: - Computed
  private var resolvedForeground: Color {
    isEnabled ? style.foreground : Color.Text.secondary
  }

  private var resolvedBackground: Color {
    isEnabled ? style.background : Color.Surface.tertiary
  }

  private var resolvedBorder: Color {
    isEnabled ? style.border : .clear
  }

  // MARK: - Body
  func body(content: Content) -> some View {
    content
      .font(font)
      .fontWeight(fontWeight)
      .foregroundStyle(resolvedForeground)
      .tint(resolvedForeground)
      .padding(.vertical, vPadding ?? style.vPadding)
      .padding(.horizontal, hPadding)
      .background(resolvedBackground)
      .clipShape(.rect(cornerRadius: .Radius.button))
      .overlay(
        RoundedRectangle(cornerRadius: .Radius.button)
          .strokeBorder(resolvedBorder, lineWidth: style.borderWidth)
      )
  }
}

extension View {

  /// Applies the design system's button appearance for `style`.
  func actionStyle(
    _ style: ActionStyle,
    font: Font = .subheadline,
    fontWeight: Font.Weight = .bold,
    vPadding: CGFloat? = nil,
    hPadding: CGFloat = 20
  ) -> some View {
    modifier(
      ActionStyleViewModifier(
        style: style,
        font: font,
        fontWeight: fontWeight,
        vPadding: vPadding,
        hPadding: hPadding
      ))
  }
}

#Preview {
  VStack(spacing: 12) {
    Text("Add medal").actionStyle(.primary)
    Text("Choose photo").actionStyle(.secondary)
    Text("Fill from race").actionStyle(.tertiary)
    Text("Skip for now").actionStyle(.plain)
    Text("Delete medal").actionStyle(.destructive)
  }  // VStack
  .padding()
  .background(Color.Background.primary)
}

#Preview("Disabled") {
  VStack(spacing: 12) {
    Text("Add medal").actionStyle(.primary)
    Text("Choose photo").actionStyle(.secondary)
    Text("Delete medal").actionStyle(.destructive)
  }  // VStack
  .padding()
  .background(Color.Background.primary)
  .disabled(true)
}
