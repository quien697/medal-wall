//
//  ProfileSummarySection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-05.
//

import SwiftUI

struct ProfileSummarySection: View {
  private let threeColumns = [
    GridItem(.flexible(minimum: 80), spacing: 8),
    GridItem(.flexible(minimum: 80), spacing: 8),
    GridItem(.flexible(minimum: 80), spacing: 8)
  ]
  private let twoColumns = [
    GridItem(.flexible(minimum: 160), spacing: 8),
    GridItem(.flexible(minimum: 160), spacing: 8)
  ]

  let totalMedals: Int
  let fullCount: Int
  let halfCount: Int
  let bestFullTime: String
  let bestHalfTime: String

  var body: some View {
    PageSection {
      LazyVGrid(columns: threeColumns, spacing: 8) {
        StatCard(title: "\(totalMedals)", subtitle: "Medals")
        StatCard(title: "\(fullCount)", subtitle: "Full")
        StatCard(title: "\(halfCount)", subtitle: "Half")
      }

      LazyVGrid(columns: twoColumns, spacing: 8) {
        StatCard(
          title: bestFullTime,
          titleFont: .TypeScale.Numeric.medium,
          subtitle: "Best Full"
        )
        StatCard(
          title: bestHalfTime,
          titleFont: .TypeScale.Numeric.medium,
          subtitle: "Best Half"
        )
      }
    }  // PageSection
  }
}

#Preview {
  ProfileSummarySection(
    totalMedals: 9,
    fullCount: 5,
    halfCount: 4,
    bestFullTime: "05:12:20",
    bestHalfTime: "-"
  )
}
