//
//  EditRaceView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import PhotosUI

struct EditRaceView: View {
  // MARK: - Environment
  @Environment(UserManager.self) private var userManager
  @Environment(\.dismiss) private var dismiss
  // MARK: - State
  @State private var viewModel: EditRaceViewModel
  @State private var errorWrapper: ErrorWrapper?
  @State private var isPresentingPhotoPicker: Bool = false
  @State private var isPresentingCropImageView: Bool = false
  @State private var selectedPhoto: PhotosPickerItem?
  @State private var rawPickedImage: UIImage?
  
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
        
        EditRaceLocationSection(
          country: $viewModel.country,
          province: $viewModel.province,
          city: $viewModel.city,
          district: $viewModel.district
        )
      } // Form
      .navigationTitle("\(viewModel.mode.displayName) Race")
      .navigationBarTitleDisplayMode(.inline)
      .scrollContentBackground(.hidden)
      .background(Color.Background.primary)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .cancel) {
            dismiss()
          }
        } // ToolbarItem
        
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
        } // ToolbarItem
      } // toolbar
      .task {
        await viewModel.loadExistingPhoto()
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
      .onChange(of: viewModel.error) { _, error in
        if let error {
          errorWrapper = ErrorWrapper(error: error)
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
      .sheet(item: $errorWrapper, onDismiss: {
        viewModel.error = nil
      }) { wrapper in
        ErrorView(errorWrapper: wrapper)
      } // sheet
    } // NavigationStack
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
