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
    Section("Distances") {
      FlowLayout(spacing: 6) {
        ForEach(distances.sorted()) { distance in
          HStack(spacing: 6) {
            Text(distance.displayLabel)

            Button {
              onRemove(distance)
            } label: {
              Image(systemName: "xmark")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(Color.Text.tertiary)
            }
            .buttonStyle(.plain)
          }
          .tagStyle(.neutralInCard)
        }

        Button {
          onAdd()
        } label: {
          Image(systemName: "plus")
            .tagStyle(.neutralInCard)
        }
        .buttonStyle(.plain)
      }  // FlowLayout
    }
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
