//
//  ShimmerViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-07-21.
//

import SwiftUI

/// A view modifier that sweeps a soft highlight across its content to signal loading.
/// Apply it to a neutral-filled shape to produce a skeleton placeholder. Honors Reduce
/// Motion by falling back to the static fill with no sweep.
struct ShimmerViewModifier: ViewModifier {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion
  @State private var isAnimating: Bool = false

  func body(content: Content) -> some View {
    content
      .overlay {
        if !reduceMotion {
          GeometryReader { proxy in
            let width = proxy.size.width
            LinearGradient(
              gradient: Gradient(stops: [
                .init(color: .clear, location: 0),
                .init(color: Color.white.opacity(0.45), location: 0.5),
                .init(color: .clear, location: 1)
              ]),
              startPoint: .leading,
              endPoint: .trailing
            )
            .frame(width: width * 0.6)
            .offset(x: isAnimating ? width : -width * 0.6)
          }  // GeometryReader
        }
      }
      .mask(content)
      .onAppear {
        guard !reduceMotion else { return }
        withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
          isAnimating = true
        }
      }
  }
}

extension View {

  /// Sweeps a loading highlight across this view, masked to its shape.
  func shimmering() -> some View {
    modifier(ShimmerViewModifier())
  }
}

#Preview("Shimmer") {
  VStack(spacing: 24) {
    RoundedRectangle(cornerRadius: 16)
      .fill(Color.Card.Background.tertiary)
      .frame(width: 120, height: 120)
      .shimmering()

    Circle()
      .fill(Color.Card.Background.tertiary)
      .frame(width: 80, height: 80)
      .shimmering()
  }  // VStack
  .padding()
}
