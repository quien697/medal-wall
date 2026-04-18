//
//  ProfileSummarySection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-05.
//

import SwiftUI

struct ProfileSummarySection: View {
  let totalMedals: Int
  let bestFullTime: String
  let bestHalfTime: String
  
  private let columns = [
    GridItem(.flexible(minimum: 80), spacing: 15),
    GridItem(.flexible(minimum: 80), spacing: 15),
    GridItem(.flexible(minimum: 80), spacing: 15),
  ]
  
  var body: some View {
    SectionContainer {
      LazyVGrid(columns: columns, spacing: 20) {
        StatGridItem(
          title: "\(totalMedals)",
          subTitle: "Medals",
          titleColor: Color.Gold.primary
        )
        
        StatGridItem(
          title: bestFullTime,
          subTitle: "Best Full",
          titleColor: Color.Gold.primary
        )
        
        StatGridItem(
          title: bestHalfTime,
          subTitle: "Best Half",
          titleColor: Color.Gold.primary
        )
      }
    }
  }
}

#Preview(traits: .sampleData) {
  
  ProfileSummarySection(
    totalMedals: 5,
    bestFullTime: "05:12:20",
    bestHalfTime: "02:02:19"
  )
}
