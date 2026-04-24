//
//  EditRaceEditionView.swift
//  MedalWall
//
//  Created by Quien on 2026-03-24.
//

import SwiftUI
import PhotosUI
import SwiftData

struct EditRaceEditionView: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss
  // MARK: - State
  @State private var isPresentingPhotoPicker: Bool = false
  @State private var isPresentingCropImageView: Bool = false
  @State private var isPresentingAddDistance: Bool = false
  @State private var selectedPhoto: PhotosPickerItem?
  @State private var rawPickedImage: UIImage?
  @State private var errorWrapper: ErrorWrapper?
  @State private var viewModel: EditRaceEditionViewModel
  // MARK: - Properties
  let onAction: (DraftRaceEdition) -> Void
  
  // MARK: - Init
  init(
    mode: ItemEditMode,
    edition: DraftRaceEdition? = nil,
    onAction: @escaping (DraftRaceEdition) -> Void
  ) {
    self.onAction = onAction
    self._viewModel = State(initialValue: EditRaceEditionViewModel(mode: mode, edition: edition))
  }
  
  // MARK: - Body
  var body: some View {
    NavigationStack {
      VStack {
        EditPhotoPicker(
          photo: viewModel.draftEdition.photo,
          hint: "Tap to \(viewModel.draftEdition.photo == nil ? "add a new" : "update the") race photo,\nor leave empty to use the race logo.",
          photoView: { RaceImage(photo: viewModel.draftEdition.photo, imageType: .raceHero) },
          onChooseFromLibrary: {
            isPresentingPhotoPicker = true
          },
          onRemove: {
            selectedPhoto = nil
            rawPickedImage = nil
            viewModel.clearPhoto()
          }
        )
        
        Form {
          EditRaceEditionDateSection(
            isOneDay: viewModel.draftEdition.isOneDay,
            year: $viewModel.draftEdition.year,
            startDate: $viewModel.draftEdition.startDate,
            endDate: $viewModel.draftEdition.endDate,
            minYear: viewModel.minYear,
            maxYear: viewModel.maxYear,
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
          
          EditRaceEditionDistanceSection(
            distances: viewModel.draftEdition.distances,
            onRemove: {
              viewModel.removeDistance($0)
            },
            onAdd: {
              isPresentingAddDistance = true
            }
          )
        } // Form
      } // VStack
      .navigationTitle("\(viewModel.mode.displayName) Edition")
      .navigationBarTitleDisplayMode(.inline)
      .scrollContentBackground(.hidden)
      .background(Color.Background.primary)
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          Button(role: .confirm) {
            onAction(viewModel.draftEdition)
            dismiss()
          }
          .disabled(!viewModel.isFormValid)
        }
      }
      .photosPicker(
        isPresented: $isPresentingPhotoPicker,
        selection: $selectedPhoto,
        matching: .images
      )
      .onChange(of: selectedPhoto) { _, newItem in
        guard let newItem else { return }
        Task {
          if let data = try? await newItem.loadTransferable(type: Data.self),
             let uiImage = UIImage(data: data) {
            rawPickedImage = uiImage
            isPresentingCropImageView = true
          } else {
            errorWrapper = ErrorWrapper(error: AppError.photoDataInvalid)
          }
        }
      }
      .sheet(isPresented: $isPresentingCropImageView, onDismiss: {
        selectedPhoto = nil
        rawPickedImage = nil
      }) {
        CropImageView(
          image: rawPickedImage,
          cropShape: .square
        ) { croppedImage in
          if let croppedImage {
            viewModel.updatePhoto(with: croppedImage)
          }
        }
      }
      .sheet(isPresented: $isPresentingAddDistance) {
        AddDistanceView { newDistance in
          do {
            try viewModel.addDistance(newDistance)
          } catch {
            errorWrapper = ErrorWrapper(error: AppError.duplicateDistance)
          }
        }
        .presentationDetents([.medium])
      }
      .sheet(item: $errorWrapper) { wrapper in
        ErrorView(errorWrapper: wrapper)
      }
    } // NavigationStack
  }
}

#Preview("Add Mode") {
  NavigationStack {
    EditRaceEditionView(
      mode: .add,
      edition: nil,
      onAction: { _ in }
    )
  }
}

#Preview("Edit Mode", traits: .sampleData) {
  NavigationStack {
    EditRaceEditionView(
      mode: .edit,
      edition: DraftRaceEdition(from: Race.sampleData.first!.editions.first!),
      onAction: { _ in }
    )
  }
}
