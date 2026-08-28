//
//  ProfileAchievementRow.swift
//  MedalWall
//
//  Created by Quien on 2026-03-06.
//

import SwiftUI

struct ProfileAchievementRow: View {
  let trackName: LocalizedStringKey
  let progress: AchievementProgress

  var body: some View {
    HStack {
      TierBadge(tier: progress.unlockedTier)

      VStack(alignment: .leading) {
        Text(trackName)
          .font(.TypeScale.headline)
          .foregroundStyle(Color.Text.primary)

        Text(progress.unlockedTier?.name ?? .appLocalized("Not started"))
          .font(.TypeScale.caption)
          .foregroundStyle(Color.Text.secondary)

        if let nextTier = progress.nextTier {
          meter

          Text("\(progress.currentCount) of \(nextTier.threshold) \u{2192} \(nextTier.name)")
            .font(.TypeScale.caption)
            .foregroundStyle(Color.Text.secondary)
        } else if let unlockedTier = progress.unlockedTier {
          meter

          Text("\(progress.currentCount) of \(unlockedTier.threshold)")
            .font(.TypeScale.caption)
            .foregroundStyle(Color.Text.secondary)
        }
      }  // VStack

      Spacer()
    }  // HStack
    .frame(maxWidth: .infinity)
    .surfaceStyle()
  }

  /// The track's progress toward its next tier — gold, because a tier is earned.
  private var meter: some View {
    GeometryReader { proxy in
      ZStack(alignment: .leading) {
        Capsule()
          .fill(Color.Surface.tertiary)

        Capsule()
          .fill(Color.Record.primary)
          .frame(width: proxy.size.width * progress.progressFraction)
      }  // ZStack
    }  // GeometryReader
    .frame(height: 8)
  }
}

#Preview("Locked") {
  ProfileAchievementRow(
    trackName: "Full Marathon",
    progress: AchievementProgress.compute(persistedMilestone: 0, liveCount: 0)
  )
}

#Preview("In progress") {
  ProfileAchievementRow(
    trackName: "Half Marathon",
    progress: AchievementProgress.compute(persistedMilestone: 5, liveCount: 7)
  )
}

#Preview("Maxed") {
  ProfileAchievementRow(
    trackName: "Full Marathon",
    progress: AchievementProgress.compute(persistedMilestone: 100, liveCount: 120)
  )
}
