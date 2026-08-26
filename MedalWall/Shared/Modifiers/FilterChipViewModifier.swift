//
//  FilterChipViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-08-25.
//

import SwiftUI

/// The selection state of a filter chip.
///
/// A filter chip is a control, so it is always a capsule — the shape is what
/// tells the reader it can be tapped. Facts about a medal take a `TagStyle`.
enum FilterChipStyle {
  case selected
  case unselected

  fileprivate var foreground: Color {
    switch self {
    case .selected: Color.Pigment.paper
    case .unselected: Color.Text.secondary
    }
  }

  fileprivate var background: Color {
    switch self {
    case .selected: Color.Pigment.inkNavy
    case .unselected: Color.Surface.primary
    }
  }

  fileprivate var border: Color {
    switch self {
    case .selected: .clear
    case .unselected: Color.Border.primary
    }
  }
}

/// A view modifier that paints a label as a filter chip.
struct FilterChipViewModifier: ViewModifier {

  // MARK: - Environment
  @Environment(\.isEnabled) private var isEnabled

  // MARK: - Properties
  let style: FilterChipStyle

  // MARK: - Computed
  private var resolvedForeground: Color {
    isEnabled ? style.foreground : Color.Text.secondary
  }

  private var resolvedBackground: Color {
    isEnabled ? style.background : Color.Surface.tertiary
  }

  // MARK: - Body
  func body(content: Content) -> some View {
    content
      .font(.caption)
      .fontWeight(.bold)
      .foregroundStyle(resolvedForeground)
      .padding(.vertical, 8)
      .padding(.horizontal, 14)
      .background(resolvedBackground)
      .clipShape(.capsule)
      .overlay(
        Capsule()
          .strokeBorder(isEnabled ? style.border : .clear, lineWidth: 1)
      )
  }
}

extension View {

  /// Applies the design system's filter chip appearance for `style`.
  func filterChipStyle(_ style: FilterChipStyle) -> some View {
    modifier(FilterChipViewModifier(style: style))
  }
}

#Preview {
  HStack(spacing: 8) {
    Text("All").filterChipStyle(.selected)
    Text("2019").filterChipStyle(.unselected)
    Text("全馬").filterChipStyle(.unselected)
    Text("Taipei").filterChipStyle(.unselected)
  }  // HStack
  .padding()
  .background(Color.Background.primary)
}
