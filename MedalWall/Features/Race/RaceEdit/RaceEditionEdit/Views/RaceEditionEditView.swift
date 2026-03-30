//
//  RaceEditionEditView.swift
//  MedalWall
//
//  Created by Quien on 2026-03-24.
//

import SwiftUI
import PhotosUI
import SwiftData

enum RaceEditionEditMode { case add, edit }

struct RaceEditionEditView: View {
  @Environment(\.dismiss) private var dismiss
  @State private var isShowingPhotoPicker: Bool = false
  @State private var isShowingCropImageView: Bool = false
  @State private var selectedPhotoItem: PhotosPickerItem?
  @State private var viewModel: RaceEditionEditViewModel
  let onAction: (DraftRaceEdition) -> Void
  
  init(
    mode: RaceEditionEditMode,
    edition: DraftRaceEdition?,
    onAction: @escaping (DraftRaceEdition) -> Void
  ) {
    self.onAction = onAction
    self._viewModel = State(initialValue: RaceEditionEditViewModel(mode: mode, edition: edition))
  }
  
  var body: some View {
    Form {
      RaceEditionEditLogoSection(
        photo: viewModel.draftEdition.photo,
        cropPhoto: viewModel.draftEdition.cropPhoto,
        onChooseFromLibrary: {
          isShowingPhotoPicker = true
        },
        onCrop: {
          isShowingCropImageView = true
        },
        onRemove: {
          selectedPhotoItem = nil
          viewModel.clearPhoto()
        }
      )
      
      RaceEditionEditDateSection(
        isOneDay: viewModel.draftEdition.isOneDay,
        year: $viewModel.draftEdition.year,
        startDate: $viewModel.draftEdition.startDate,
        endDate: $viewModel.draftEdition.endDate,
        yearDateRange: viewModel.yearDateRange,
        minEndDate: viewModel.minEndDate,
        maxEndDate: viewModel.maxEndDate,
        onToggleOneDay: {
          viewModel.toggleOneDay()
        },
        onUpdateYear: {
          viewModel.updateYear($0)
        },
        onUpdateStartDate: {
          viewModel.updateStartDate($0)
        }
      )
      
      Section("Distnaces") {
        // distances
      }
    } // Form
    .navigationTitle("\(viewModel.mode == .add ? "Add" : "Edit") Edition")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button(viewModel.mode == .add ? "Add" : "Update") {
          onAction(viewModel.draftEdition)
          dismiss()
        }
        .disabled(!viewModel.isFormValid)
      }
    }
    .photosPicker(
      isPresented: $isShowingPhotoPicker,
      selection: $selectedPhotoItem,
      matching: .images
    )
    .onChange(of: selectedPhotoItem) { _, newItem in
      guard let newItem else { return }
      
      Task {
        do {
          if let data = try await newItem.loadTransferable(type: Data.self) {
            viewModel.clearPhoto()
            viewModel.updatePhoto(with: data)
          } else {
            //            errorWrapper = ErrorWrapper(error: AppError.photoDataInvalid)
          }
        } catch {
          //          errorWrapper = ErrorWrapper(error: AppError.photoLoadFailed)
        }
      } // Task
    }
    .sheet(isPresented: $isShowingCropImageView) {
      CropImageView(
        image: viewModel.draftEdition.photo,
        type: .raceHero,
      ) { cropppedImage in
        if let cropppedImage {
          viewModel.updateCropPhoto(with: cropppedImage)
        }
      }
    }
    
    //    .sheet(isPresented: $isShowingAddDistanceSheet) {
    //      NavigationStack {
    //        RaceDistanceEditView(
    //          mode: .add,
    //          distance: .default,
    //          onUpdate: { newDistance in
    //            do {
    //              try viewModel.addDistance(newDistance)
    //            } catch {
    //              errorWrapper = ErrorWrapper(
    //                error: error,
    //                guidance: "This distance already exists for this edition."
    //              )
    //            }
    //          }
    //        )
    //      }
    //      .presentationDetents([.medium])
    //    }
    //    .sheet(item: $editingDistance) { distance in
    //      NavigationStack {
    //        RaceDistanceEditView(
    //          mode: .edit,
    //          distance: distance,
    //          onUpdate: { updatedDistance in
    //            do {
    //              try viewModel.updateDistance(old: distance, with: updatedDistance)
    //            } catch {
    //              errorWrapper = ErrorWrapper(
    //                error: error,
    //                guidance: "This distance already exists for this edition."
    //              )
    //            }
    //          }
    //        )
    //      }
    //      .presentationDetents([.medium])
    //    }
  }
}

#Preview("Add Mode") {
  NavigationStack {
    RaceEditionEditView(
      mode: .add,
      edition: nil,
      onAction: { _ in }
    )
  }
}

#Preview("Edit Mode", traits: .sampleData) {
  NavigationStack {
    RaceEditionEditView(
      mode: .edit,
      edition: DraftRaceEdition(from: Race.sampleData.first!.editions.first!),
      onAction: { _ in }
    )
  }
}

