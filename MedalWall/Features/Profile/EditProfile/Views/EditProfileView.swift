//
//  EditProfileView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-04.
//

import SwiftUI
import PhotosUI
import SwiftData

struct EditProfileView: View {
  // MARK: - Environment
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  // MARK: - State
  @State private var viewModel: EditProfileViewModel
  @State private var errorWrapper: ErrorWrapper?
  @State private var isPresentingPhotoPicker: Bool = false
  @State private var isPresentingCropImageView: Bool = false
  @State private var selectedPhoto: PhotosPickerItem?
  @State private var rawPickedImage: UIImage?
  @State private var shouldDismiss: Bool = false
  
  init(mode: ItemEditMode, profile: User? = nil) {
    self._viewModel = State(initialValue: EditProfileViewModel(mode: mode, profile: profile))
  }
  
  var body: some View {
    NavigationStack {
      Form {
        EditPhotoPicker(
          photo: viewModel.avatar,
          hint: "Tap to \(viewModel.avatar == nil ? "add a" : "update your") profile photo",
          photoView: {
            AvatarImage(photo: viewModel.avatar)
          },
          onChooseFromLibrary: {
            isPresentingPhotoPicker = true
          },
          onCrop: {},
          onRemove: {
            selectedPhoto = nil
            rawPickedImage = nil
            viewModel.clearPhoto()
          }
        )
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        
        EditProfileInfoSection(
          firstName: $viewModel.userName.firstName,
          lastName: $viewModel.userName.lastName,
          gender: $viewModel.gender,
          birthday: $viewModel.birthday,
          isBirthdaySet: $viewModel.isBirthdaySet
        )
        
        EditProfileBioSection(bio: $viewModel.bio)
      } // Form
      .navigationTitle("\(viewModel.mode.displayName) Profile")
      .navigationBarTitleDisplayMode(.inline)
      .scrollContentBackground(.hidden)
      .background(Color.Background.primary)
      .onAppear {
        viewModel.configure(context: modelContext)
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .close) {
            dismiss()
          }
        }
        
        ToolbarItem(placement: .confirmationAction) {
          Button(role: .confirm) {
            do {
              try viewModel.save()
              dismiss()
            } catch {
              shouldDismiss = true
              errorWrapper = ErrorWrapper(error: AppError.userSaveFailed)
            }
          }
          .disabled(!viewModel.isFormValid)
        }
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
      .sheet(isPresented: $isPresentingCropImageView, onDismiss: {
        selectedPhoto = nil
        rawPickedImage = nil
      }) {
        CropImageView(
          image: rawPickedImage,
          cropShape: .circle
        ) { croppedImage in
          if let croppedImage {
            viewModel.updatePhoto(with: croppedImage)
          }
        }
      }
      .sheet(item: $errorWrapper, onDismiss: {
        if shouldDismiss { dismiss() }
      }) { wrapper in
        ErrorView(errorWrapper: wrapper)
      }
    } // NavigationStack
  }
}

#Preview {
  EditProfileView(mode: .edit, profile: User.guest)
}
