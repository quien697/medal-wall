//
//  RaceDistanceSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI
import SwiftData

struct RaceDistanceSection: View {
  @Binding var isPresented: Bool
  
  let distances: [RaceDistance]
  let onUpdate: (RaceDistance, RaceDistance) -> Void
  let onDelete: (RaceDistance) -> Void
  
  var body: some View {
    let groupedDistances = distances.groupedByType()
    
    Section("Race Distance") {
      if distances.isEmpty {
        HStack {
          Text("")
          
          Image(systemName: "figure.run")
            .padding(8)
            .background(.gray.opacity(0.2))
            .clipShape(.circle)
          
          Text("No distances yet")
          
          Spacer()
        }
      } else {
        ForEach(RaceDistanceType.allCases) { type in
          if let distances = groupedDistances[type], !distances.isEmpty {
            Text(type.displayName)
              .font(.headline)
            
            ForEach(distances) { distance in
              RaceDistanceSectionRow(distance: distance) { updatedDistance in
                onUpdate(distance, updatedDistance)
              }
              .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                  onDelete(distance)
                } label: {
                  Label("Delete", systemImage: "trash")
                }
              }
            }
          }
        }
      }
      
      Button {
        withAnimation {
          isPresented = true
        }
      } label: {
        HStack {
          Image(systemName: "plus")
            .padding(8)
            .clipShape(.circle)
          
          Text("Add distance")
        }
      }
    } // Section
  }
}

#Preview(traits: .sampleData) {
  Form {
    RaceDistanceSection(
      isPresented: .constant(true),
      distances: [],
      onUpdate: { _, _ in },
      onDelete: { _ in }
    )
  }
}
