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
  
  @State private var isShowingPhotoPicker: Bool = false
  @State private var isShowingCropImageView: Bool = false
  @State private var isShowingAddDistanceView: Bool = false
  @State private var selectedRacePhotoItem: PhotosPickerItem?
  @State private var newRaceDistance = RaceDistance.default
  @State private var shouldDismiss: Bool = false
  @State private var errorWrapper: ErrorWrapper?
  @State private var viewModel: RaceEditViewModel

  init(race: Race?) {
    self._viewModel = State(initialValue: RaceEditViewModel(race: race))
  }
  
  var body: some View {
    Form {
      RacePhotoSection(
        photo: viewModel.photo,
        cropPhoto: viewModel.cropPhoto,
        onChooseFromLibrary: {
          isShowingPhotoPicker = true
        },
        onCrop: {
          isShowingCropImageView = true
        },
        onRemove: {
          selectedRacePhotoItem = nil
          viewModel.clearPhoto()
        }
      )
      
//      RaceInfoSection(
//        name: $viewModel.name,
//        date: $viewModel.date
//      )
      
      RaceLocationSection(
        country: $viewModel.country,
        province: $viewModel.province,
        city: $viewModel.city,
        district: $viewModel.district
      )
      
      RaceDistanceSection(
        isPresented: $isShowingAddDistanceView,
        distances: viewModel.distances,
        onUpdate: { distance, updatedDistance in
          do {
            try viewModel.updateDistance(old: distance, with: updatedDistance)
          } catch {
            errorWrapper = ErrorWrapper(error: AppError.duplicateDistance)
          }
        },
        onDelete: { distance in
          viewModel.deleteDistance(distance)
        }
      )
      
//      RaceAdditionalSection(url: $viewModel.url)
    } // Form
    .task {
      do {
        try viewModel.attachContext(modelContext)
      } catch {
        errorWrapper = ErrorWrapper(error: AppError.contextNotAttached)
      }
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
            errorWrapper = ErrorWrapper(error: AppError.raceSaveFailed)
          }
        }
        .disabled(!viewModel.isFormValid)
      } // ToolbarItem
    } // toolbar
    .photosPicker(isPresented: $isShowingPhotoPicker, selection: $selectedRacePhotoItem, matching: .images)
    .onChange(of: selectedRacePhotoItem) { _, newItem in
      guard let newItem else { return }

      Task {
        do {
          if let data = try await newItem.loadTransferable(type: Data.self) {
            viewModel.clearPhoto()
            viewModel.updatePhoto(with: data)
          } else {
            errorWrapper = ErrorWrapper(error: AppError.photoDataInvalid)
          }
        } catch {
          errorWrapper = ErrorWrapper(error: AppError.photoLoadFailed)
        }
      } // Task
    }
    .sheet(isPresented: $isShowingCropImageView) {
      CropImageView(
        image: viewModel.photo,
        type: .raceHero,
      ) { cropppedImage in
        if let cropppedImage {
          viewModel.updateCropPhoto(with: cropppedImage)
        }
      }
    }
    .sheet(isPresented: $isShowingAddDistanceView) {
      RaceDistanceAddView(onSave: { newDistance in
        do {
          try viewModel.addDistance(newDistance)
        } catch {
          errorWrapper = ErrorWrapper(error: AppError.duplicateDistance)
        }
      })
    }
    .sheet(item: $errorWrapper, onDismiss: {
      if shouldDismiss {
        dismiss()
      }
    }) { wrapper in
      ErrorView(errorWrapper: wrapper)
    }
  }
}

#Preview() {
  NavigationStack {
    RaceEditView(race: Race.sampleData.first!)
  }
}
