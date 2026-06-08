//
//  EditProfileView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-04.
//

import CropImage
import PhotosUI
import SwiftUI

struct EditProfileView: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss
  @Environment(UserManager.self) private var userManager
  // MARK: - State
  @State private var viewModel: EditProfileViewModel
  @State private var isLoading = false
  @State private var errorWrapper: ErrorWrapper?
  @State private var isPresentingPhotoPicker: Bool = false
  @State private var isPresentingCropImageView: Bool = false
  @State private var selectedPhoto: PhotosPickerItem?
  @State private var rawPickedImage: UIImage?
  @State private var shouldDismiss: Bool = false

  // MARK: - Init
  init(profile: User) {
    self._viewModel = State(initialValue: EditProfileViewModel(profile: profile))
  }

  // MARK: - Body
  var body: some View {
    NavigationStack {
      Form {
        EditPhotoPicker(
          photo: viewModel.photo,
          photoView: {
            AvatarImage(photo: viewModel.photo)
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

        EditProfileInfoSection(
          firstName: $viewModel.userName.firstName,
          lastName: $viewModel.userName.lastName,
          gender: $viewModel.gender,
          birthday: $viewModel.birthday,
          isBirthdaySet: $viewModel.isBirthdaySet
        )

        EditProfileBioSection(bio: $viewModel.bio)
      }  // Form
      .navigationTitle("Edit Profile")
      .navigationBarTitleDisplayMode(.inline)
      .scrollContentBackground(.hidden)
      .background(Color.Background.primary)
      .disabled(isLoading)
      .task {
        await viewModel.loadExistingPhoto()
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .close) {
            dismiss()
          }
        }

        ToolbarItem(placement: .confirmationAction) {
          Button(role: .confirm) {
            Task {
              isLoading = true
              defer { isLoading = false }

              do {
                var updatedUser = viewModel.makeUpdatedUser()
                if viewModel.isPhotoChanged && viewModel.photo == nil {
                  updatedUser.photoUrl = nil
                }
                let updatedUserPhoto = viewModel.isPhotoChanged ? viewModel.photo : nil
                try await userManager.updateUser(updatedUser, photo: updatedUserPhoto)
                dismiss()
              } catch {
                shouldDismiss = true
                errorWrapper = ErrorWrapper(error: AppError.userSaveFailed)
              }
            }
          }
          .disabled(!viewModel.isFormValid || isLoading)
        }
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
      .sheet(
        isPresented: $isPresentingCropImageView,
        onDismiss: {
          selectedPhoto = nil
          rawPickedImage = nil
        },
        content: {
          CropImageView(image: rawPickedImage, cropShape: .circle) { croppedImage in
            if let croppedImage {
              viewModel.updatePhoto(with: croppedImage)
            }
          }
        }
      )
      .sheet(
        item: $errorWrapper,
        onDismiss: {
          if shouldDismiss { dismiss() }
        },
        content: { wrapper in
          ErrorView(errorWrapper: wrapper)
        }
      )
    }  // NavigationStack
  }
}

#Preview {
  EditProfileView(profile: User.preview)
    .environment(UserManager())
}
