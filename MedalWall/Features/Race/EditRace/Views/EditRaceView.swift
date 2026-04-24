//
//  EditRaceView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import PhotosUI
import SwiftData

struct EditRaceView: View {
  // MARK: - Environment
  @Environment(UserManager.self) private var userManager
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  // MARK: - State
  @State private var viewModel: EditRaceViewModel
  @State private var errorWrapper: ErrorWrapper?
  @State private var isPresentingPhotoPicker: Bool = false
  @State private var isPresentingCropImageView: Bool = false
  @State private var selectedPhoto: PhotosPickerItem?
  @State private var rawPickedImage: UIImage?
  @State private var shouldDismiss: Bool = false
  @State private var isPresentingAddEdition: Bool = false
  // MARK: - Namespace
  @Namespace private var namespace
  private let addEdition: String = "addEdition"
  
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
          hint: "Tap to \(viewModel.photo == nil ? "add a new" : "update the") race photo",
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
          url: $viewModel.url
        )
        
        EditRaceLocationSection(
          country: $viewModel.country,
          province: $viewModel.province,
          city: $viewModel.city,
          district: $viewModel.district
        )
        
        EditRaceEditionSection(
          editions: viewModel.editions,
          racePhoto: viewModel.photo,
          namespace: namespace,
          transitionID: addEdition,
          onAdd: {
            isPresentingAddEdition = true
          },
          onUpdate: { originalEdition, updatedEdition in
            do {
              try viewModel.updateEdition(old: originalEdition, with: updatedEdition)
            } catch {
              errorWrapper = ErrorWrapper(error: AppError.duplicateEdition)
            }
          },
          onDelete: { edition in
            viewModel.deleteEdition(edition)
          }
        )
      } // Form
      .onAppear {
        viewModel.configure(context: modelContext)
      }
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
          Button(role: .confirm) {
            do {
              if let userId = userManager.currentUserID {
                try viewModel.save(by: userId)
                dismiss()
              } else {
                errorWrapper = ErrorWrapper(error: AppError.userLoadFailed)
              }
            } catch {
              shouldDismiss = true
              errorWrapper = ErrorWrapper(error: AppError.raceSaveFailed)
            }
          }
          .disabled(!viewModel.isFormValid)
        } // ToolbarItem
      } // toolbar
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
      .navigationDestination(isPresented: $isPresentingAddEdition) {
        AddRaceEditionView { newEdition in
          viewModel.addEdition(newEdition)
        }
        .navigationTransition(.zoom(sourceID: addEdition, in: namespace))
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
        if shouldDismiss {
          dismiss()
        }
      }) { wrapper in
        ErrorView(errorWrapper: wrapper)
      }
    } // NavigationStack
  }
}

#Preview("Add mode") {
  @Previewable @Environment(\.modelContext) var modelContext
  
  NavigationStack {
    EditRaceView(mode: .add, race: Race.sampleData.first!)
  }
  .environment(UserManager(modelContext: modelContext))
}

#Preview("Edit mode") {
  @Previewable @Environment(\.modelContext) var modelContext
  
  NavigationStack {
    EditRaceView(mode: .edit, race: Race.sampleData.first!)
  }
  .environment(UserManager(modelContext: modelContext))
}
