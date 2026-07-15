//
//  AchievementBadgeView.swift
//  MedalWall
//
//  Created by Quien on 2026-07-14.
//

import SwiftUI

/// Renders an evolving badge for an achievement tier — one more ring appears
/// per successive tier. A nil tier renders the locked (not-yet-unlocked) state.
struct AchievementBadgeView: View {
  let tier: AchievementTier?

  private var ringCount: Int {
    guard let tier, let index = AchievementTier.allCases.firstIndex(of: tier) else { return 0 }
    return index + 1
  }

  private var tintColor: Color {
    tier == nil ? Color.Text.tertiary : Color.Gold.primary
  }

  var body: some View {
    ZStack {
      ForEach(0..<ringCount, id: \.self) { index in
        Circle()
          .strokeBorder(tintColor, lineWidth: 2)
          .padding(CGFloat(index * 5))
      }  // ForEach

      Image(systemName: tier == nil ? "star" : "star.fill")
        .font(.title2)
        .foregroundStyle(tintColor)
    }  // ZStack
    .frame(width: 56, height: 56)
  }
}

#Preview("Locked") {
  AchievementBadgeView(tier: nil)
}

#Preview("Tier 1 - First Finish") {
  AchievementBadgeView(tier: .firstFinish)
}

#Preview("Tier 4 - Quarter Century") {
  AchievementBadgeView(tier: .quarterCentury)
}

#Preview("Tier 7 - Centurion") {
  AchievementBadgeView(tier: .centurion)
}
