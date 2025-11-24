//
//  RaceDistanceSectionRow.swift
//  MedalWall
//
//  Created by Quien on 2025-11-23.
//

import SwiftUI

struct RaceDistanceSectionRow: View {
  let distance: RaceDistance
  let onSave: (RaceDistance) -> Void
  
  var body: some View {
    NavigationLink {
      NavigationStack {
        RaceDistanceEditView(
          mode: .edit,
          distance: distance,
          onSave: onSave
        )
      }
    } label: {
      HStack {
        Text("")
        
        Image(systemName: "figure.run")
          .padding(8)
          .background(distance.category.color)
          .clipShape(.circle)
        
        Text(distance.category.description)
        
        Spacer()
        
        Text(distance.type.displayName)
      }
    }
  }
}

#Preview {
  RaceDistanceSectionRow(distance: RaceDistance.default, onSave: { _ in print("onSave") })
}
