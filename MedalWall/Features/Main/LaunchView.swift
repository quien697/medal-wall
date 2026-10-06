//
//  LaunchView.swift
//  MedalWall
//
//  Created by Quien on 2026-10-05.
//

import SwiftUI

/// Shown while the app works out who is signed in and loads their profile — at launch with a
/// saved session, and right after signing in. The iOS mockup's Launch screen.
struct LaunchView: View {
  /// The mockup's 72 pt bar on its 390 pt screen, kept in that proportion on any screen width.
  private let barWidthRatio: CGFloat = 72 / 390

  var body: some View {
    GeometryReader { proxy in
      VStack(spacing: 0) {
        Spacer()

        VStack(spacing: .Space.panel) {
          RingSeal(.record, size: .hero) {
            Text(verbatim: "MW")
              .font(.TypeScale.Wordmark.monogram)
              .tracking(.Tracking.monogram)
              .foregroundStyle(Color.Record.earned)
          }  // RingSeal

          Text("Medal Wall")
            .font(.TypeScale.Wordmark.name)
            .tracking(.Tracking.wordmark)
            .foregroundStyle(Color.Text.primary)
        }  // VStack

        Spacer()

        VStack(spacing: .Space.row) {
          ProgressBar()
            .frame(width: proxy.size.width * barWidthRatio)

          Text("Loading your collection")
            .font(.TypeScale.caption)
            .foregroundStyle(Color.Text.secondary)
        }  // VStack
        .padding(.bottom, .Space.section)
      }  // VStack
      .frame(maxWidth: .infinity)
    }  // GeometryReader
    .background(Color.Background.primary)
  }
}

#Preview {
  LaunchView()
}
