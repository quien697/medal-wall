//
//  ProfileAchievementsSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-05.
//

import SwiftUI

struct ProfileAchievementsSection: View {
  var body: some View {
    SectionContainer(title: "achievements") {
      VStack(spacing: 15) {
        ProfileAchievementRow()
        
        ProfileAchievementRow()
        
        ProfileAchievementRow()
      }
    }
  }
}

#Preview {
  ProfileAchievementsSection()
}
