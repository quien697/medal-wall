//
//  ProfileAchievementRow.swift
//  MedalWall
//
//  Created by Quien on 2026-03-06.
//

import SwiftUI

struct ProfileAchievementRow: View {
  var body: some View {
    HStack {
      Image(systemName: "star")
        .font(.title2)
      
      VStack(alignment: .leading) {
        Text("Top 6")
          .font(.headline)
          .fontWeight(.bold)
        
        Text("The 6 World Marathon Majors")
          .font(.footnote)
          .foregroundStyle(Color.Text.tertiary)
      }
      
      Spacer()
      
      Image(systemName: "checkmark.circle.fill")
        .font(.title2)
    }
    .frame(maxWidth: .infinity)
    .modifier(SurfaceStyle(
      background: Color.Card.Background.primary,
      paddingV: 15,
      paddingH: 15
    ))
  }
}

#Preview {
  ProfileAchievementRow()
}
