//
//  RaceEditView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

enum Mode { case add, edit }

struct RaceEditView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var newRaceDistance = RaceDistance.default
  @State private var isShowRaceDistanceAddView = false
  @State private var saveRaceErrorWrapper: ErrorWrapper?
  @State private var addDistanceErrorWrapper: ErrorWrapper?
  @State var viewModel: RaceEditViewModel
  
  var body: some View {
    Form {
      RaceInfoSection(viewModel: $viewModel)
      
      RaceLocationSection(viewModel: $viewModel)
      
      RaceDistanceSection(
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
            saveRaceErrorWrapper = ErrorWrapper(error: error, guidance: "Race event was not recorded. Try again later.")
          }
        }
        .disabled(!viewModel.isFormValid)
      } // ToolbarItem
    } // toolbar
    .sheet(isPresented: $isShowRaceDistanceAddView) {
      RaceDistanceAddView(onSave: { newDistance in
        do {
          try viewModel.addDistance(newDistance)
        } catch {
         addDistanceErrorWrapper = ErrorWrapper(error: error, guidance: "Duplicate distance found. Please choose a different distance.")
        }
      })
    }
    .sheet(item: $saveRaceErrorWrapper) {
      dismiss()
    } content: { wrapper in
      ErrorView(errorWrapper: wrapper)
    }
    .sheet(item: $addDistanceErrorWrapper, onDismiss: nil) { wrapper in
      ErrorView(errorWrapper: wrapper)
    } // sheet
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  let context = try! ModelContext(SampleData.makeSharedContext())
  NavigationStack {
    RaceEditView(viewModel: RaceEditViewModel(race: races[0], context: context))
  }
}
