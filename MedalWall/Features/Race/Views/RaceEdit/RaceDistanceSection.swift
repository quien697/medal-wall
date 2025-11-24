//
//  RaceDistanceSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI
import SwiftData

struct RaceDistanceSection: View {
  @Environment(\.dismiss) private var dismiss
  @Bindable var viewModel: RaceEditViewModel
  @Binding var isPresented: Bool
  @State private var errorWrapper: ErrorWrapper?
  
  var body: some View {
    let groupedDistances = viewModel.distances.groupedByType()
    
    Section("Race Distance") {
      if viewModel.distances.isEmpty {
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
                do {
                  try viewModel.updateDistance(old: distance, with: updatedDistance)
                } catch {
                  errorWrapper = ErrorWrapper(error: error, guidance: "Duplicate distance found. Please choose a different distance.")
                }
              }
              .swipeActions(edge: .trailing) {
                Button(role: .destructive) {
                  viewModel.deleteDistance(distance)
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
    .sheet(item: $errorWrapper, onDismiss: nil) { wrapper in
      ErrorView(errorWrapper: wrapper)
    } // sheet
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  
  Form {
    RaceDistanceSection(
      viewModel: RaceEditViewModel(race: races.first!),
      isPresented: .constant(true)
    )
  }
}
