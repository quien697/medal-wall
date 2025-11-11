//
//  RaceDIstanceSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI
import SwiftData

struct RaceDIstanceSection: View {
  @Binding var viewModel: RaceEditViewModel
  @Binding var isPresented: Bool
  
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
              RaceDistanceEditView(distance: viewModel.binding(for: distance))
                .navigationTitle("Edit Distance")
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
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  let context = try! ModelContext(SampleData.makeSharedContext())
  
  Form {
    RaceDIstanceSection(
      viewModel: .constant(RaceEditViewModel(race: races.first!, context: context)),
      isPresented: .constant(true)
    )
  }
}
