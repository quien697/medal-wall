//
//  RaceDistanceAddView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-10.
//

import SwiftUI
import SwiftData

struct RaceDistanceAddView: View {
  @Environment(\.dismiss) private var dismiss
  @State var distance: RaceDistance = .default
  @State var viewModel: RaceEditViewModel
  
  var body: some View {
    NavigationStack{
      RaceDistanceEditView(distance: $distance)
        .navigationTitle("Add Distance")
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
              dismiss()
            }
          }
          
          ToolbarItem(placement: .confirmationAction) {
            Button("Add") {
              viewModel.addDistance(distance)
              dismiss()
            }
          }
        }
    }
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  let context = try! ModelContext(SampleData.makeSharedContext())
  
  NavigationStack{
    RaceDistanceAddView(
      viewModel: RaceEditViewModel(race: races.first!, context: context)
    )
  }
}
