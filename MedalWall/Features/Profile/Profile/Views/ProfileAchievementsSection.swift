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

  var body: some View {
    PageSection(title: "Achievements") {
      VStack(spacing: 15) {
        ProfileAchievementRow(trackName: "Full Marathon", progress: fullMarathonProgress)

        ProfileAchievementRow(trackName: "Half Marathon", progress: halfMarathonProgress)
      }  // VStack
    }  // PageSection
  }
}

#Preview {
  ProfileAchievementsSection(
    fullMarathonProgress: AchievementProgress.compute(liveCount: 10),
    halfMarathonProgress: AchievementProgress.compute(liveCount: 2)
  )
}
