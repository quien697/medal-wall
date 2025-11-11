//
//  RaceEditView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct RaceEditView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var newRaceDistance = RaceDistance.default
  @State private var isShowRaceDistanceAddView = false
  @State var viewModel: RaceEditViewModel
  
  var body: some View {
    Form {
      RaceInfoSection(viewModel: $viewModel)
      
      RaceLocationSection(viewModel: $viewModel)
      
      RaceDIstanceSection(
        viewModel: $viewModel,
        isPresented: $isShowRaceDistanceAddView
      )
      
      RaceAdditionalSection(viewModel: $viewModel)
    } // Form
    .navigationTitle("\(viewModel.isNewRace ? "Add" : "Edit") Race")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          dismiss()
        }
      } // ToolbarItem
      
      ToolbarItem(placement: .confirmationAction) {
        Button(viewModel.isNewRace ? "Add" : "Save") {
          do {
            try viewModel.save()
            dismiss()
          } catch {
            print("Error saving race: \(error)")
          }
        }
        .disabled(!viewModel.isFormValid)
      } // ToolbarItem
    } // toolbar
    .sheet(isPresented: $isShowRaceDistanceAddView) {
      RaceDistanceAddView(viewModel: viewModel)
    }
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  let context = try! ModelContext(SampleData.makeSharedContext())
  NavigationStack {
    RaceEditView(viewModel: RaceEditViewModel(race: races[0], context: context))
  }
}
