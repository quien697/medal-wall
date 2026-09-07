//
//  MedalDetailStatsSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-07.
//

import SwiftUI

struct MedalDetailStatsSection: View {
  // MARK: - Properties
  private let spacing: CGFloat = 10
  let finishTime: String
  let averagePace: String
  let overallPlacement: String
  let totalParticipants: String
  let division: String
  let divisionPlacement: String
  let divisionTotal: String
  let genderPlacement: String
  let genderTotal: String

  // MARK: - Computed
  var columns: [GridItem] {
    [GridItem](
      repeating: GridItem(.flexible(minimum: 80), spacing: spacing),
      count: 2
    )
  }

  // MARK: - Body
  var body: some View {
    PageSection(title: "Stats") {
      LazyVGrid(columns: columns, spacing: spacing) {
        MedalDetailStatsGridItem(
          title: "Finish Time",
          headline: finishTime,
          headLineColor: Color.Record.primary
        )

        MedalDetailStatsGridItem(
          title: "AVG Pace",
          headline: averagePace,
        )

        MedalDetailStatsGridItem(
          title: "Overall",
          headline: overallPlacement,
          subHeadLine: totalParticipants,
          headLineColor: Color.Record.primary
        )

        MedalDetailStatsGridItem(
          title: "Gender",
          headline: genderPlacement,
          subHeadLine: genderTotal
        )

        MedalDetailStatsGridItem(
          title: "Division Group",
          headline: division,
          subHeadLine: ""
        )

        MedalDetailStatsGridItem(
          title: "Division",
          headline: divisionPlacement,
          subHeadLine: divisionTotal
        )
      }  // LazyVGrid
    }  // PageSection
  }
}

#Preview {
  ScrollView {
    MedalDetailStatsSection(
      finishTime: "5:10:10",
      averagePace: "5'31\" /km",
      overallPlacement: "5000",
      totalParticipants: "of 7000",
      division: "M30-40",
      divisionPlacement: "50",
      divisionTotal: "of 1000",
      genderPlacement: "300",
      genderTotal: "of 4000"
    )

    MedalDetailStatsSection(
      finishTime: "-- : -- : --",
      averagePace: "--'-- \"",
      overallPlacement: "--",
      totalParticipants: "",
      division: "--",
      divisionPlacement: "--",
      divisionTotal: "",
      genderPlacement: "--",
      genderTotal: ""
    )
  }
  .background(Color.Background.primary)
}
