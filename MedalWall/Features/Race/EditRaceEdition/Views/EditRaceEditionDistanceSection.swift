//
//  EditRaceEditionDistanceSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-31.
//

import SwiftUI

struct EditRaceEditionDistanceSection: View {
  let distances: [RaceDistance]
  var onRemove: (RaceDistance) -> Void
  var onAdd: () -> Void

  var body: some View {
    Section {
      FlowLayout(spacing: 6) {
        ForEach(distances.sorted()) { distance in
          HStack(spacing: 6) {
            Text(distance.displayLabel)

            Button {
              onRemove(distance)
            } label: {
              Image(systemName: "xmark")
                .font(.TypeScale.overline)
                .foregroundStyle(Color.Text.tertiary)
            }
            .buttonStyle(.plain)
          }
          .chipStyle(.neutral)
        }
      }  // FlowLayout
    } header: {
      HStack {
        Text("Distances")
          .sectionTitleStyle()

        Spacer()

        Button {
          onAdd()
        } label: {
          HStack {
            Image(systemName: "plus")

            Text("Distance")
          }
          .actionStyle(.primary, font: .TypeScale.sectionTitle, vPadding: 5, hPadding: 10)
        }
      }
    }  // Section
    .listRowBackground(Color.Surface.primary)
  }
}

#Preview {
  let distances = RaceEdition.sampleData.first!.distances

  Form {
    EditRaceEditionDistanceSection(
      distances: distances,
      onRemove: { _ in },
      onAdd: {}
    )

    EditRaceEditionDistanceSection(
      distances: [],
      onRemove: { _ in },
      onAdd: {}
    )
  }
}
