//
//  ProfileAchievementRow.swift
//  MedalWall
//
//  Created by Quien on 2026-03-06.
//

import SwiftUI

struct ProfileAchievementRow: View {
  let trackName: String
  let progress: AchievementProgress

  var body: some View {
    HStack {
      AchievementBadgeView(tier: progress.unlockedTier)

      VStack(alignment: .leading) {
        Text(trackName)
          .font(.headline)
          .fontWeight(.bold)

        Text(progress.unlockedTier?.name ?? "Not started")
          .font(.footnote)
          .foregroundStyle(Color.Text.tertiary)

        if let nextTier = progress.nextTier {
          ProgressView(value: Double(progress.currentCount), total: Double(nextTier.threshold))

          Text("\(progress.currentCount) of \(nextTier.threshold) \u{2192} \(nextTier.name)")
            .font(.caption)
            .foregroundStyle(Color.Text.tertiary)
        }
      }  // VStack

      Spacer()
    }  // HStack
    .frame(maxWidth: .infinity)
    .surfaceStyle()
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
    progress: AchievementProgress.compute(persistedMilestone: 100, liveCount: 100)
  )
}
