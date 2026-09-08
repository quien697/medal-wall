//
//  MedalDetailResultSection.swift
//  MedalWall
//
//  Created by Quien on 2026-09-08.
//

import SwiftUI

/// What the medal was run to: the finish time first, then the placements around it.
///
/// Every field renders whether or not the medal records it, so the band also says what is
/// still the user's to fill in. Finish leads on its own line because it is the answer the
/// screen exists to give; the rest pair off.
struct MedalDetailResultSection: View {
  // MARK: - Properties
  private let spacing: CGFloat = 12
  let finishTime: String
  let isPersonalRecord: Bool
  let averagePaceValue: String
  let averagePaceUnit: String?
  let overallPlacement: String
  let overallTotal: String?
  let genderPlacement: String
  let genderTotal: String?
  let divisionLabel: String
  let divisionPlacement: String
  let divisionTotal: String?

  // MARK: - Computed
  var columns: [GridItem] {
    [GridItem](
      repeating: GridItem(.flexible(minimum: 80), spacing: spacing, alignment: .leading),
      count: 2
    )
  }

  // MARK: - Body
  var body: some View {
    PageSection(title: "The result") {
      VStack(alignment: .leading, spacing: spacing) {
        MedalDetailResultItem(
          label: .appLocalized("Finish"),
          value: finishTime,
          suffix: nil,
          isRecord: isPersonalRecord
        )

        LazyVGrid(columns: columns, alignment: .leading, spacing: spacing) {
          MedalDetailResultItem(
            label: .appLocalized("Avg pace"),
            value: averagePaceValue,
            suffix: averagePaceUnit,
            isRecord: false
          )

          MedalDetailResultItem(
            label: .appLocalized("Overall"),
            value: overallPlacement,
            suffix: overallTotal,
            isRecord: false
          )

          MedalDetailResultItem(
            label: .appLocalized("Gender"),
            value: genderPlacement,
            suffix: genderTotal,
            isRecord: false
          )

          MedalDetailResultItem(
            label: divisionLabel,
            value: divisionPlacement,
            suffix: divisionTotal,
            isRecord: false
          )
        }  // LazyVGrid
      }  // VStack
    }  // PageSection
  }
}

#Preview("Fully recorded") {
  ScrollView {
    MedalDetailResultSection(
      finishTime: "03:30:24",
      isPersonalRecord: true,
      averagePaceValue: "4'59\"",
      averagePaceUnit: "/km",
      overallPlacement: "1058",
      overallTotal: "/ 7373",
      genderPlacement: "233",
      genderTotal: "/ 6081",
      divisionLabel: "Division M30-34",
      divisionPlacement: "523",
      divisionTotal: "/ 1633"
    )
  }  // ScrollView
  .background(Color.Background.primary)
}

#Preview("Finish time only") {
  ScrollView {
    MedalDetailResultSection(
      finishTime: "01:45:30",
      isPersonalRecord: false,
      averagePaceValue: "4'59\"",
      averagePaceUnit: "/km",
      overallPlacement: "—",
      overallTotal: nil,
      genderPlacement: "—",
      genderTotal: nil,
      divisionLabel: "Division",
      divisionPlacement: "—",
      divisionTotal: nil
    )
  }  // ScrollView
  .background(Color.Background.primary)
}

#Preview("Nothing recorded") {
  ScrollView {
    MedalDetailResultSection(
      finishTime: "No time recorded",
      isPersonalRecord: false,
      averagePaceValue: "—",
      averagePaceUnit: nil,
      overallPlacement: "—",
      overallTotal: nil,
      genderPlacement: "—",
      genderTotal: nil,
      divisionLabel: "Division",
      divisionPlacement: "—",
      divisionTotal: nil
    )
  }  // ScrollView
  .background(Color.Background.primary)
}
