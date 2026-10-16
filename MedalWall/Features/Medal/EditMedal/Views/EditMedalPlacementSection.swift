//
//  EditMedalPlacementSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-13.
//

import SwiftUI

struct EditMedalPlacementSection: View {
  @Binding var overallPlacement: Int?
  @Binding var totalParticipants: Int?
  @Binding var genderPlacement: Int?
  @Binding var genderTotal: Int?
  @Binding var division: Division?
  @Binding var divisionPlacement: Int?
  @Binding var divisionTotal: Int?

  var body: some View {
    Section {
      EditMedalPlacementRow(
        label: "Overall",
        placement: $overallPlacement,
        total: $totalParticipants
      )

      EditMedalPlacementRow(
        label: "Gender",
        placement: $genderPlacement,
        total: $genderTotal
      )

      Picker(selection: $division) {
        Text("Not Set").tag(Division?.none)

        Section("Female") {
          ForEach(AgeGroup.fiveYearCases, id: \.self) { ageGroup in
            let option = Division(gender: .female, ageGroup: ageGroup)
            Text(option.displayName).tag(Division?.some(option))
          }  // ForEach
          ForEach(AgeGroup.tenYearCases, id: \.self) { ageGroup in
            let option = Division(gender: .female, ageGroup: ageGroup)
            Text(option.displayName).tag(Division?.some(option))
          }  // ForEach
        }  // Section

        Section("Male") {
          ForEach(AgeGroup.fiveYearCases, id: \.self) { ageGroup in
            let option = Division(gender: .male, ageGroup: ageGroup)
            Text(option.displayName).tag(Division?.some(option))
          }  // ForEach
          ForEach(AgeGroup.tenYearCases, id: \.self) { ageGroup in
            let option = Division(gender: .male, ageGroup: ageGroup)
            Text(option.displayName).tag(Division?.some(option))
          }  // ForEach
        }  // Section
      } label: {
        Text("Division Group")
          .fieldStyle(.label)
      }  // Picker

      if division != nil {
        EditMedalPlacementRow(
          label: "Division",
          placement: $divisionPlacement,
          total: $divisionTotal
        )
      }
    } header: {
      Text("Placement (Optional)")
        .sectionTitleStyle()
    }  // Section
  }
}

#Preview {
  let medal = Medal.sampleData.first!

  Form {
    EditMedalPlacementSection(
      overallPlacement: .constant(medal.overallPlacement),
      totalParticipants: .constant(medal.totalParticipants),
      genderPlacement: .constant(medal.genderPlacement),
      genderTotal: .constant(medal.genderTotal),
      division: .constant(medal.parsedDivision),
      divisionPlacement: .constant(medal.divisionPlacement),
      divisionTotal: .constant(medal.divisionTotal)
    )
  }
}
