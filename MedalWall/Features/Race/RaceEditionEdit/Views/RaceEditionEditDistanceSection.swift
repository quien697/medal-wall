//
//  RaceEditionEditDistanceSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-31.
//

import SwiftUI

struct RaceEditionEditDistanceSection: View {
  let distances: [RaceDistance]
  var onRemove: (RaceDistance) -> Void
  var onAdd: () -> Void
  
  var body: some View {
    Section("Distances") {
      FlowLayout(spacing: 10) {
        ForEach(distances.sorted()) { distance in
          HStack(spacing: 6) {
            Text(distance.displayLabel)
            
            Image(systemName: "xmark")
              .font(.caption2)
              .fontWeight(.semibold)
              .foregroundStyle(Color.Text.tertiary)
              .onTapGesture {
                onRemove(distance)
              }
          }
          .secondaryButtonStyle(
            vPadding: 6,
            hPadding: 10
          )
        }
        
        Button {
          onAdd()
        } label: {
          Image(systemName: "plus")
            .goldOutLineButtonStyle()
        }
      } // FlowLayout
    }
  }
}

#Preview {
  let distances = Race.sampleData.first!.editions.first!.distances
  
  Form {
    RaceEditionEditDistanceSection(
      distances: distances,
      onRemove: { _ in },
      onAdd: {}
    )
    
    RaceEditionEditDistanceSection(
      distances: [],
      onRemove: { _ in },
      onAdd: {}
    )
  }
}
