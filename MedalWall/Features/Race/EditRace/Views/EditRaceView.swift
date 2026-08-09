//
//  EditRaceView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import CropImage
import PhotosUI
import SwiftUI

struct EditRaceView: View {
  // MARK: - Environment
  @Environment(UserManager.self) private var userManager
  @Environment(\.dismiss) private var dismiss

  // MARK: - State
  @State private var viewModel: EditRaceViewModel
  @State private var errorWrapper: ErrorWrapper?
  @State private var isPresentingPhotoPicker: Bool = false
  @State private var isPresentingCropImageView: Bool = false
  @State private var isPresentingAddEdition = false
  @State private var isPresentingPlacePicker = false
  @State private var selectedEdition: DraftRaceEdition?
  @State private var selectedPhoto: PhotosPickerItem?
  @State private var rawPickedImage: UIImage?

  // MARK: - Namespace
  @Namespace private var namespace
  private let addEdition = "addEdition"

  // MARK: - Init
  init(mode: ItemEditMode, race: Race? = nil) {
    self._viewModel = State(initialValue: EditRaceViewModel(mode: mode, race: race))
  }

  // MARK: - Body
  var body: some View {
    NavigationStack {
      Form {
        EditPhotoPicker(
          photo: viewModel.photo,
          photoView: {
            RaceImage(photo: viewModel.photo, imageType: .raceHero)
          },
          onChooseFromLibrary: {
            isPresentingPhotoPicker = true
          },
          onRemove: {
            selectedPhoto = nil
            rawPickedImage = nil
            viewModel.clearPhoto()
          }
        )
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)

        EditRaceInfoSection(
          name: $viewModel.name,
          url: $viewModel.websiteUrl
        )

        EditPlaceSection(place: viewModel.place) {
          isPresentingPlacePicker = true
        }

        if viewModel.mode == .edit, let raceId = viewModel.raceId {
          EditRaceEditionSection(
            raceId: raceId,
            editions: viewModel.displayedEditions,
            isLoading: viewModel.isEditionsLoading,
            namespace: namespace,
            transitionID: addEdition,
            onTapAddEdition: { isPresentingAddEdition = true },
            onTapEdition: { selectedEdition = $0 },
            onAdd: { viewModel.stageAddEdition($0) },
            onUpdate: { viewModel.stageUpdateEdition($0) },
            onDelete: viewModel.stageDeleteEdition
          )
        }
      }  // Form
      .navigationTitle("\(viewModel.mode.displayName) Race")
      .navigationBarTitleDisplayMode(.inline)
      .scrollContentBackground(.hidden)
      .background(Color.Background.primary)
      .task {
        await viewModel.loadExistingPhoto()
        await viewModel.loadEditions()
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .cancel) {
            dismiss()
          }
        }  // ToolbarItem

        ToolbarItem(placement: .confirmationAction) {
          if viewModel.isLoading {
            ProgressView()
          } else {
            Button(role: .confirm) {
              guard let userId = userManager.currentUserID else {
                errorWrapper = ErrorWrapper(error: AppError.userLoadFailed)
                return
              }
              Task {
                await viewModel.save(by: userId)
                if viewModel.error == nil {
                  dismiss()
                }
              }
            }
            .disabled(!viewModel.isFormValid)
          }
        }  // ToolbarItem
      }  // toolbar
      .photosPicker(
        isPresented: $isPresentingPhotoPicker,
        selection: $selectedPhoto,
        matching: .images
      )
      .onChange(of: selectedPhoto) { _, newItem in
        guard let newItem else { return }
        Task {
          if let data = try? await newItem.loadTransferable(type: Data.self),
            let uiImage = UIImage(data: data)
          {
            rawPickedImage = uiImage
            isPresentingCropImageView = true
          } else {
            errorWrapper = ErrorWrapper(error: AppError.photoDataInvalid)
          }
        }
      }
      .onChange(of: viewModel.error) { _, error in
        if let error {
          errorWrapper = ErrorWrapper(error: error)
        }
      }
      .sheet(
        isPresented: $isPresentingCropImageView,
        onDismiss: {
          selectedPhoto = nil
          rawPickedImage = nil
        },
        content: {
          CropImageView(
            image: rawPickedImage,
            cropShape: .square
          ) { croppedImage in
            if let croppedImage {
              viewModel.updatePhoto(with: croppedImage)
            }
          }
        }
      )
      .sheet(isPresented: $isPresentingPlacePicker) {
        PlacePickerView { viewModel.place = $0 }
      }
      .sheet(isPresented: $isPresentingAddEdition) {
        if let raceId = viewModel.raceId {
          EditRaceEditionView(
            mode: .add,
            raceId: raceId,
            onCommit: { draft in
              viewModel.stageAddEdition(draft)
            }
          )
          .navigationTransition(.zoom(sourceID: addEdition, in: namespace))
        }
      }
      .sheet(item: $selectedEdition) { draft in
        if let raceId = viewModel.raceId {
          EditRaceEditionView(
            mode: .edit,
            raceId: raceId,
            edition: RaceEdition(
              id: draft.id,
              raceId: raceId,
              year: draft.year,
              startDate: draft.startDate,
              endDate: draft.endDate,
              photoUrl: draft.existingPhotoUrl,
              distances: draft.distances,
              createdBy: draft.createdBy
            ),
            onCommit: { updatedDraft in
              viewModel.stageUpdateEdition(updatedDraft)
            },
            onDelete: {
              viewModel.stageDeleteEdition(id: draft.id)
            }
          )
        }
      }
      .sheet(
        item: $errorWrapper,
        onDismiss: {
          viewModel.error = nil
        },
        content: { wrapper in
          ErrorView(errorWrapper: wrapper)
        }
      )  // sheet
    }  // NavigationStack
  }
}

#Preview("Add mode") {
  EditRaceView(mode: .add)
    .environment(UserManager())
}

#Preview("Edit mode") {
  EditRaceView(mode: .edit, race: Race.sampleData.first!)
    .environment(UserManager())
}
