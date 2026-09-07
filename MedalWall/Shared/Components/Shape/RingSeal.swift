//
//  RingSeal.swift
//  MedalWall
//
//  Created by Quien on 2026-08-26.
//

import SwiftUI

/// The colours the two rings are drawn in.
///
/// Locked keeps the same silhouette in neutral greys — no gold until it is earned.
enum RingSealStyle {
  case record
  case locked

  fileprivate var outerColor: Color {
    switch self {
    case .record: Color.TierBadge.earnedOuter
    case .locked: Color.TierBadge.lockedOuter
    }
  }

  fileprivate var innerColor: Color {
    switch self {
    case .record: Color.TierBadge.earnedInner
    case .locked: Color.TierBadge.lockedInner
    }
  }
}

/// The seal's ring geometry, in points.
///
/// The two sizes are not one scaled from the other — the design system fixes both
/// the inner ratio and the stroke weights per size, so each case carries its own
/// four values.
enum RingSealSize {
  case hero
  case tier

  fileprivate var diameter: CGFloat {
    switch self {
    case .hero: 108
    case .tier: 60
    }
  }

  fileprivate var strokeWidth: CGFloat {
    switch self {
    case .hero: 4
    case .tier: 2
    }
  }

  fileprivate var innerDiameter: CGFloat {
    switch self {
    case .hero: 84
    case .tier: 48
    }
  }

  fileprivate var innerStrokeWidth: CGFloat { 2 }
}

/// The double-ring seal — the app's signature mark. Two concentric rings frame
/// arbitrary centre content: the `MW` wordmark on the login hero, a reached
/// threshold or `lock.fill` on an achievement tier badge.
///
/// The rings carry the mark and the caller styles its own content, because the
/// centre colour does not follow from the ring style — the wordmark and the tier
/// numeral diverge in dark appearance.
struct RingSeal<Content: View>: View {
  let style: RingSealStyle
  let size: RingSealSize
  let content: Content

  init(_ style: RingSealStyle, size: RingSealSize, @ViewBuilder content: () -> Content) {
    self.style = style
    self.size = size
    self.content = content()
  }

  var body: some View {
    ZStack {
      Circle()
        .strokeBorder(style.outerColor, lineWidth: size.strokeWidth)

      Circle()
        .strokeBorder(style.innerColor, lineWidth: size.innerStrokeWidth)
        .frame(width: size.innerDiameter, height: size.innerDiameter)

      content
    }  // ZStack
    .frame(width: size.diameter, height: size.diameter)
  }
}

#Preview("Hero") {
  RingSeal(.record, size: .hero) {
    Text(verbatim: "MW")
      .font(.system(size: 28, weight: .black))
      .tracking(-1.12)
      .foregroundStyle(Color.Record.primary)
  }  // RingSeal
  .padding()
  .background(Color.Background.primary)
}

#Preview("Tier") {
  HStack(spacing: 14) {
    RingSeal(.locked, size: .tier) {
      Image(systemName: "lock.fill")
        .font(.system(size: 20))
        .foregroundStyle(Color.TierBadge.lockedIcon)
    }  // RingSeal

    RingSeal(.record, size: .tier) {
      Text(verbatim: "10")
        .font(.system(size: 17, weight: .black))
        .monospacedDigit()
        .foregroundStyle(Color.TierBadge.earnedNumeral)
    }  // RingSeal
  }  // HStack
  .padding()
  .background(Color.Background.primary)
}
