//
//  RaceEditView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import PhotosUI
import SwiftData

enum RaceEditMode { case add, edit }

struct RaceEditView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var selectedRacePhotoItem: PhotosPickerItem?
  @State private var newRaceDistance = RaceDistance.default
  @State private var isShowRaceDistanceAddView: Bool = false
  @State private var errorWrapper: ErrorWrapper?
  @State private var shouldDismiss: Bool = false
  @State private var viewModel: RaceEditViewModel
  
  init(race: Race?) {
    self._viewModel = State(initialValue: RaceEditViewModel(race: race))
  }
  
  var body: some View {
    Form {
      RacePhotoSection(
        data: $viewModel.photoData,
        image: $viewModel.photo
      )
      
      RaceInfoSection(
        name: $viewModel.name,
        date: $viewModel.date
      )
      
      RaceLocationSection(
        country: $viewModel.country,
        province: $viewModel.province,
        city: $viewModel.city,
        district: $viewModel.district
      )
      
      RaceDistanceSection(
        isPresented: $isShowRaceDistanceAddView,
        distances: viewModel.distances,
        onUpdate: { distance, updatedDistance in
          do {
            try viewModel.updateDistance(old: distance, with: updatedDistance)
          } catch {
            errorWrapper = ErrorWrapper(error: error, guidance: "Duplicate distance found. Please choose a different distance.")
          }
        },
        onDelete: { distance in
          viewModel.deleteDistance(distance)
        }
      )
      
      RaceAdditionalSection(url: $viewModel.url)
    } // Form
    .task {
      viewModel.attachContext(modelContext)
    }
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
            shouldDismiss = true
            errorWrapper = ErrorWrapper(error: error, guidance: "Race event was not recorded. Try again later.")
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
          errorWrapper = ErrorWrapper(error: error, guidance: "Duplicate distance found. Please choose a different distance.")
        }
      })
    }
    .sheet(item: $errorWrapper, onDismiss: {
        if shouldDismiss {
            dismiss()
          shouldDismiss = false
        }
    }) { wrapper in
        ErrorView(errorWrapper: wrapper)
    }
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  
  NavigationStack {
    RaceEditView(race: races.first!)
  }
}
