//
//  TierBadge.swift
//  MedalWall
//
//  Created by Quien on 2026-08-26.
//

import SwiftUI

/// The achievement tier mark — the double-ring seal with the reached threshold in
/// its centre. A nil tier renders the locked state: same silhouette, neutral
/// greys, `lock.fill` where the numeral would sit.
struct TierBadge: View {
  let tier: AchievementTier?

  /// Point size for the tier numeral. Drops one notch from three digits on so a
  /// threshold like `100` keeps clear space inside the inner ring.
  static func numeralFontSize(forThreshold threshold: Int) -> CGFloat {
    String(max(0, threshold)).count >= 3 ? 15 : 17
  }

  var body: some View {
    RingSeal(tier == nil ? .locked : .record, size: .tier) {
      if let tier {
        Text(tier.threshold, format: .number.grouping(.never))
          .font(.system(size: Self.numeralFontSize(forThreshold: tier.threshold), weight: .black))
          .monospacedDigit()
          .foregroundStyle(Color.TierBadge.earnedNumeral)
      } else {
        Image(systemName: "lock.fill")
          .font(.system(size: 20))
          .foregroundStyle(Color.TierBadge.lockedIcon)
      }
    }  // RingSeal
  }
}

#Preview("Locked") {
  TierBadge(tier: nil)
}

#Preview("Tier 1 - First Finish") {
  TierBadge(tier: .firstFinish)
}

#Preview("Tier 5 - Quarter Century") {
  TierBadge(tier: .quarterCentury)
}

#Preview("Tier 7 - Centurion") {
  TierBadge(tier: .centurion)
}
