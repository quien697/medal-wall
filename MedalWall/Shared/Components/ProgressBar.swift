//
//  ProgressBar.swift
//  MedalWall
//
//  Created by Quien on 2026-10-06.
//

import SwiftUI

/// The design system's `ProgressBar`: one height, a stone track and an ink fill. Given a value
/// it fills that fraction of whatever width it is offered; without one there is no progress to
/// report, so a segment slides across the track on a loop — held still at the start when
/// Reduce Motion is on. Decorative: callers state the progress in text beside it.
struct ProgressBar: View {
  // MARK: - Environment
  @Environment(\.accessibilityReduceMotion) private var isReduceMotionOn

  // MARK: - State
  /// The sliding segment's position as a fraction of the track. It starts just off the left
  /// edge, so every loop slides in and out without a jump.
  @State private var slidePosition = -ProgressBar.segmentFraction

  // MARK: - Properties
  /// The fraction filled, 0 to 1; nil while there is no progress to report.
  let value: Double?
  /// `component.ProgressBar.height`.
  private static let height: CGFloat = 6
  /// The sliding segment's share of the track.
  private static let segmentFraction: CGFloat = 0.4

  // MARK: - Init
  /// A bar filled to `value`, a fraction from 0 to 1.
  init(value: Double) {
    self.value = value
  }

  /// A bar with no progress to report, showing only that something is happening.
  init() {
    self.value = nil
  }

  // MARK: - Body
  var body: some View {
    GeometryReader { proxy in
      ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: .Radius.progressTrack)
          .fill(Color.Progress.track)

        if let value {
          RoundedRectangle(cornerRadius: .Radius.progressTrack)
            .fill(Color.Progress.fill)
            .frame(width: proxy.size.width * value)
        } else {
          RoundedRectangle(cornerRadius: .Radius.progressTrack)
            .fill(Color.Progress.fill)
            .frame(width: proxy.size.width * Self.segmentFraction)
            .offset(x: proxy.size.width * (isReduceMotionOn ? 0 : slidePosition))
        }
      }  // ZStack
      .clipShape(.rect(cornerRadius: .Radius.progressTrack))
    }  // GeometryReader
    .frame(height: Self.height)
    .accessibilityHidden(true)
    .onAppear {
      guard value == nil, !isReduceMotionOn else { return }
      withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: false)) {
        slidePosition = 1
      }
    }
  }
}

#Preview("Progress") {
  VStack(spacing: .Space.gutter) {
    ProgressBar(value: 0)
    ProgressBar(value: 0.4)
    ProgressBar(value: 1)
  }  // VStack
  .padding()
  .background(Color.Surface.primary)
}

#Preview("No Progress to Report") {
  ProgressBar()
    .frame(width: 72)
    .padding()
}
