//
//  ActionViewModifier.swift
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
  case neutral
  case plain
  case destructive

  fileprivate var foreground: Color {
    switch self {
    case .primary: Color.Background.primary
    case .secondary, .tertiary, .neutral, .plain: Color.Pigment.inkNavy
    case .destructive: Color.Status.error
    }
  }

  fileprivate var background: Color {
    switch self {
    case .primary: Color.Pigment.inkNavy
    case .secondary, .tertiary: Color.Surface.primary
    case .neutral: Color.Surface.tertiary
    case .plain, .destructive: .clear
    }
  }

  fileprivate var border: Color {
    switch self {
    case .primary, .neutral, .plain: .clear
    case .secondary: Color.Pigment.inkNavy
    case .tertiary: Color.Border.primary
    case .destructive: Color.Status.error
    }
  }

  fileprivate var borderWidth: CGFloat {
    switch self {
    case .primary, .neutral, .plain: 0
    case .secondary, .destructive: 1.5
    case .tertiary: 1
    }
  }
}

/// The shape of an action, decided by its width.
///
/// A full-width action is a rounded rectangle at `Radius.button`; anything that
/// hugs its label is a capsule. Neither prominence nor container decides this —
/// those produce exception lists. Icon-only needs no case of its own: a capsule
/// on a square frame is already a circle.
///
/// `ButtonBorderShape` names these two cases natively but cannot draw them:
/// used as a plain `Shape` it renders a capsule whatever case it was built
/// from, so the radius is lost. These stay concrete shapes.
enum ActionShape {
  case roundedRectangle
  case capsule

  var clipShape: AnyShape {
    switch self {
    case .roundedRectangle: AnyShape(RoundedRectangle(cornerRadius: .Radius.button))
    case .capsule: AnyShape(Capsule())
    }
  }

  /// Width is the predicate the shape is chosen by, so the shape owns it rather
  /// than leaving each call site to remember a matching frame.
  fileprivate var maxWidth: CGFloat? {
    switch self {
    case .roundedRectangle: .infinity
    case .capsule: nil
    }
  }

  /// Draws the border just inside the fill.
  ///
  /// `strokeBorder` needs a concrete `InsettableShape`, and `AnyShape` is not
  /// insettable — so unlike the clip, the outline cannot be erased.
  @ViewBuilder
  fileprivate func outline(_ color: Color, lineWidth: CGFloat) -> some View {
    switch self {
    case .roundedRectangle:
      RoundedRectangle(cornerRadius: .Radius.button)
        .strokeBorder(color, lineWidth: lineWidth)
    case .capsule:
      Capsule().strokeBorder(color, lineWidth: lineWidth)
    }
  }
}

/// A view modifier that paints a label as a button.
struct ActionStyleViewModifier: ViewModifier {

  // MARK: - Environment
  @Environment(\.isEnabled) private var isEnabled

  // MARK: - Properties
  let style: ActionStyle
  let shape: ActionShape
  let font: Font
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
      .foregroundStyle(resolvedForeground)
      .tint(resolvedForeground)
      .padding(.vertical, vPadding)
      .padding(.horizontal, hPadding)
      .frame(maxWidth: shape.maxWidth)
      .background(resolvedBackground)
      .clipShape(shape.clipShape)
      .overlay(shape.outline(resolvedBorder, lineWidth: style.borderWidth))
  }
}

extension View {

  /// Applies the design system's button appearance for `style` and `shape`.
  func actionStyle(
    _ style: ActionStyle,
    shape: ActionShape = .capsule,
    font: Font = .TypeScale.headline,
    vPadding: CGFloat = 13,
    hPadding: CGFloat = 20
  ) -> some View {
    modifier(
      ActionStyleViewModifier(
        style: style,
        shape: shape,
        font: font,
        vPadding: vPadding,
        hPadding: hPadding
      ))
  }
}

#Preview("Styles") {
  VStack(spacing: 12) {
    Text("Add medal").actionStyle(.primary)
    Text("Choose photo").actionStyle(.secondary)
    Text("Fill from race").actionStyle(.tertiary)
    Text("Not Set").actionStyle(.neutral)
    Text("Skip for now").actionStyle(.plain)
    Text("Delete medal").actionStyle(.destructive)
  }  // VStack
  .padding()
  .background(Color.Background.primary)
}

#Preview("Shapes") {
  VStack(spacing: 12) {
    Text("Save medal").actionStyle(.primary, shape: .roundedRectangle)
    Text("Save medal").actionStyle(.tertiary, shape: .roundedRectangle)
    Text("Select").actionStyle(.tertiary)
    Image(systemName: "plus").actionStyle(.primary, hPadding: 13)
  }  // VStack
  .padding()
  .background(Color.Background.primary)
}

#Preview("Disabled") {
  VStack(spacing: 12) {
    Text("Add medal").actionStyle(.primary, shape: .roundedRectangle)
    Text("Choose photo").actionStyle(.secondary)
    Text("Delete medal").actionStyle(.destructive)
  }  // VStack
  .padding()
  .background(Color.Background.primary)
  .disabled(true)
}
