//
//  ElevationViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-08-25.
//

import SwiftUI

/// The design system's shadow levels.
///
/// The source values are CSS `box-shadow`, whose negative spread has no SwiftUI
/// equivalent — `shadow(color:radius:x:y:)` cannot shrink a shadow before
/// blurring it. Each level is therefore approximated with a tighter radius and a
/// lower opacity than a direct blur conversion would give.
enum Elevation {
  case soft
  case lifted
  case ring

  fileprivate var color: Color {
    switch self {
    case .soft: Color.black.opacity(0.20)
    case .lifted: Color.black.opacity(0.26)
    case .ring: Color.black.opacity(0.28)
    }
  }

  fileprivate var radius: CGFloat {
    switch self {
    case .soft: 8
    case .lifted: 14
    case .ring: 6
    }
  }

  fileprivate var yOffset: CGFloat {
    switch self {
    case .soft: 6
    case .lifted: 12
    case .ring: 4
    }
  }
}

/// A view modifier that casts the design system's shadow for a given level.
struct ElevationViewModifier: ViewModifier {
  let elevation: Elevation

  func body(content: Content) -> some View {
    content
      .shadow(
        color: elevation.color,
        radius: elevation.radius,
        x: 0,
        y: elevation.yOffset
      )
  }
}

extension View {

  /// Applies the design system's shadow for `level`.
  func elevation(_ level: Elevation) -> some View {
    modifier(ElevationViewModifier(elevation: level))
  }
}

#Preview {
  VStack(spacing: 40) {
    Text("Soft")
      .surfaceStyle()
      .elevation(.soft)

    Text("Lifted")
      .surfaceStyle()
      .elevation(.lifted)

    Circle()
      .fill(Color.Surface.primary)
      .frame(width: 72, height: 72)
      .elevation(.ring)
  }  // VStack
  .padding(40)
  .background(Color.Background.primary)
}
