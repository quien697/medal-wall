//
//  EditProfileView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-04.
//

import CropImage
import SwiftUI

struct EditProfileView: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss
  @Environment(UserManager.self) private var userManager

  // MARK: - State
  @State private var viewModel: EditProfileViewModel
  @State private var errorWrapper: ErrorWrapper?

  // MARK: - Init
  init(profile: User) {
    self._viewModel = State(initialValue: EditProfileViewModel(profile: profile))
  }

  // MARK: - Body
  var body: some View {
    NavigationStack {
      Form {
        PhotoSlot(
          content: viewModel.photo.content,
          imageType: .avatar,
          cropShape: .circle,
          title: "Profile photo",
          onPick: { viewModel.photo.update(with: $0) },
          onRemove: { viewModel.photo.remove() },
          onError: { errorWrapper = ErrorWrapper(error: $0) }
        )  // PhotoSlot
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)

        EditProfileInfoSection(
          firstName: $viewModel.userName.firstName,
          lastName: $viewModel.userName.lastName,
          gender: $viewModel.gender,
          birthday: $viewModel.birthday,
        )

        EditProfileBioSection(bio: $viewModel.bio)
      }  // Form
      .navigationTitle("Edit Profile")
      .navigationBarTitleDisplayMode(.inline)
      .scrollContentBackground(.hidden)
      .background(Color.Background.primary)
      .disabled(viewModel.isLoading)
      .task {
        await viewModel.loadStoredPhoto()
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .close) {
            dismiss()
          }  // Button
          .disabled(viewModel.isLoading)
        }  // ToolbarItem

        ToolbarItem(placement: .confirmationAction) {
          if viewModel.isLoading {
            ProgressView()
          } else {
            Button(role: .confirm) {
              Task {
                do {
                  try await viewModel.save(userManager: userManager)
                  dismiss()
                } catch {
                  errorWrapper = ErrorWrapper(error: error as? AppError ?? .userSaveFailed)
                }
              }
            }  // Button
            .disabled(!viewModel.isFormValid)
          }
        }  // ToolbarItem
      }  // toolbar
      .interactiveDismissDisabled()
      .sheet(
        item: $errorWrapper,
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
