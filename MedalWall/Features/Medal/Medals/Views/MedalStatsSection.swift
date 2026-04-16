//
//  MedalStatsSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-09.
//

import SwiftUI

struct MedalStatsSection: View {
  let totalCount: Int
  let fullCount: Int
  let halfCount: Int
  
  var body: some View {
    SectionContainer {
      HStack(spacing: 16) {
        StatCard(
          title: "\(totalCount)",
          subTitle: "Total",
          titleColor: Color.Badge.Gold.primary,
          vPadding: 8
        )
        
        StatCard(
          title: "\(fullCount)",
          subTitle: "Full",
          vPadding: 8
        )
        
        StatCard(
          title: "\(halfCount)",
          subTitle: "Half",
          vPadding: 8
        )
      } // HStack
    } // SectionContainer
  }
}

#Preview {
  MedalStatsSection(
    totalCount: 10,
    fullCount: 5,
    halfCount: 4
  )
  .background(Color.Background.primary)
}
