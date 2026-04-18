//
//  ProfileSummarySection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-05.
//

import SwiftUI

struct ProfileSummarySection: View {
  private let columns = [
    GridItem(.flexible(minimum: 80), spacing: 16),
    GridItem(.flexible(minimum: 80), spacing: 16),
    GridItem(.flexible(minimum: 80), spacing: 16),
  ]
  let totalMedals: Int
  let bestFullTime: String
  let bestHalfTime: String
  
  var body: some View {
    SectionContainer {
      LazyVGrid(columns: columns, spacing: 16) {
        StatCard(title: "\(totalMedals)", subTitle: "Medals")
        StatCard(title: bestFullTime, subTitle: "Best Full")
        StatCard(title: bestHalfTime, subTitle: "Best Half")
      } // LazyVGrid
    } // SectionContainer
  }
}

#Preview {
  ProfileSummarySection(
    totalMedals: 5,
    bestFullTime: "05:12:20",
    bestHalfTime: "02:02:19"
  )
}
