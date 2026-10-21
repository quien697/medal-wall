//
//  ProfileAchievementsSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-05.
//

import SwiftUI

struct ProfileAchievementsSection: View {
  let fullMarathonProgress: AchievementProgress
  let halfMarathonProgress: AchievementProgress
  /// Shows the rows as bones, under the real title, while the medals load.
  let isShowingSkeleton: Bool

  var body: some View {
    PageSection(title: "Achievements") {
      VStack(spacing: 15) {
        ProfileAchievementRow(trackName: "Full Marathon", progress: fullMarathonProgress)

        ProfileAchievementRow(trackName: "Half Marathon", progress: halfMarathonProgress)
      }  // VStack
      .skeleton(isShowingSkeleton)
    }  // PageSection
  }
}

#Preview {
  ProfileAchievementsSection(
    fullMarathonProgress: AchievementProgress.compute(liveCount: 10),
    halfMarathonProgress: AchievementProgress.compute(liveCount: 2),
    isShowingSkeleton: false
  )
}

#Preview("Loading") {
  ProfileAchievementsSection(
    fullMarathonProgress: AchievementProgress.compute(liveCount: 4),
    halfMarathonProgress: AchievementProgress.compute(liveCount: 4),
    isShowingSkeleton: true
  )
  .background(Color.Background.primary)
}
