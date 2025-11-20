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
  @Binding var viewModel: RaceEditViewModel
  @Binding var isPresented: Bool
  @State private var errorWrapper: ErrorWrapper?
  
  var body: some View {
    Section("Race Distance") {
      if viewModel.distances.isEmpty {
        HStack {
          Image(systemName: "figure.run")
            .padding(8)
            .background(.gray.opacity(0.2))
            .clipShape(.circle)
          
          Text("No distances yet")
          
          Spacer()
        }
      } else {
        ForEach(viewModel.distances.sortedByTypeAndDistance(), id: \.self) { distance in
          NavigationLink {
            NavigationStack {
              RaceDistanceEditView(
                mode: .edit,
                distance: distance,
                onSave: { updatedDistance in
                  do {
                    try viewModel.updateDistance(old: distance, with: updatedDistance)
                  } catch {
                    errorWrapper = ErrorWrapper(error: error, guidance: "Duplicate distance found. Please choose a different distance.")
                  }
                }
              )
            }
          } label: {
            HStack {
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
        .onDelete { indices in
          viewModel.deleteDistance(at: indices)
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
  let context = try! ModelContext(SampleData.makeSharedContext())
  
  Form {
    RaceDistanceSection(
      viewModel: .constant(RaceEditViewModel(race: races.first!, context: context)),
      isPresented: .constant(true)
    )
  }
}
