//
//  EditRaceEditionView.swift
//  MedalWall
//
//  Created by Quien on 2026-03-24.
//

import CropImage
import PhotosUI
import SwiftUI

struct EditRaceEditionView: View {
  // MARK: - Environment
  @Environment(UserManager.self) private var userManager
  @Environment(\.dismiss) private var dismiss

  // MARK: - State
  @State private var isPresentingPhotoPicker = false
  @State private var isPresentingCropImageView = false
  @State private var isPresentingAddDistance = false
  @State private var isPresentingDeleteConfirm = false
  @State private var selectedPhoto: PhotosPickerItem?
  @State private var rawPickedImage: UIImage?
  @State private var errorWrapper: ErrorWrapper?
  @State private var viewModel: EditRaceEditionViewModel

  // MARK: - Properties
  private let onCommit: (DraftRaceEdition) -> Void
  private let onDelete: (() -> Void)?

  // MARK: - Init
  init(
    mode: ItemEditMode,
    edition: RaceEdition? = nil,
    draft: DraftRaceEdition? = nil,
    onCommit: @escaping (DraftRaceEdition) -> Void,
    onDelete: (() -> Void)? = nil
  ) {
    self._viewModel = State(
      initialValue: EditRaceEditionViewModel(mode: mode, edition: edition, draft: draft))
    self.onCommit = onCommit
    self.onDelete = onDelete
  }

  // MARK: - Body
  var body: some View {
    NavigationStack {
      VStack {
        EditPhotoPicker(
          photo: viewModel.photo,
          imageType: .raceHero,
          hint: viewModel.photoHint,
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
            isOneDay: viewModel.isOneDay,
            year: $viewModel.year,
            startDate: $viewModel.startDate,
            endDate: $viewModel.endDate,
            minYear: viewModel.minYear,
            maxYear: viewModel.maxYear,
            yearDateRange: viewModel.yearDateRange,
            minEndDate: viewModel.minEndDate,
            maxEndDate: viewModel.maxEndDate,
            onToggleOneDay: { viewModel.toggleOneDay() },
            onUpdateYear: { viewModel.updateYear($0) },
            onUpdateStartDate: { viewModel.updateStartDate($0) }
          )

          EditRaceEditionDistanceSection(
            distances: viewModel.distances,
            onRemove: { viewModel.removeDistance($0) },
            onAdd: { isPresentingAddDistance = true }
          )

          if viewModel.mode == .edit {
            Section {
              Button(role: .destructive) {
                isPresentingDeleteConfirm = true
              } label: {
                Text("Delete Edition")
                  .frame(maxWidth: .infinity, alignment: .center)
              }  // Button
            }  // Section
          }
        }  // Form
      }  // VStack
      .navigationTitle("\(viewModel.mode.displayName) Edition")
      .navigationBarTitleDisplayMode(.inline)
      .scrollContentBackground(.hidden)
      .background(Color.Background.primary)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .cancel) {
            dismiss()
          }
        }  // ToolbarItem

        ToolbarItem(placement: .confirmationAction) {
          Button(role: .confirm) {
            guard let userId = userManager.currentUserID else {
              errorWrapper = ErrorWrapper(error: AppError.notSignedIn)
              return
            }

            let draft = viewModel.buildDraft(userId: userId)
            onCommit(draft)
            dismiss()
          }
          .disabled(!viewModel.isFormValid)
        }  // ToolbarItem
      }  // toolbar
      .task {
        await viewModel.loadExistingPhoto()
      }
      .alert(isPresented: $isPresentingDeleteConfirm) {
        .deleteConfirmation(.edition(year: viewModel.originalYear)) {
          onDelete?()
          dismiss()
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
          CropImageView(
            image: rawPickedImage,
            cropShape: .square
          ) { croppedImage in
            if let croppedImage { viewModel.updatePhoto(with: croppedImage) }
          }
        }
      )
      .sheet(isPresented: $isPresentingAddDistance) {
        EditDistanceView(
          mode: .add,
          distance: .default,
          onAction: { newDistance in
            try viewModel.addDistance(newDistance)
          }
        )
        .presentationDetents([.medium])
      }
      .sheet(
        item: $errorWrapper,
        content: { wrapper in
          ErrorView(errorWrapper: wrapper)
        }
      )  // sheet
    }  // NavigationStack
  }
}

#Preview("Add Mode") {
  EditRaceEditionView(mode: .add, onCommit: { _ in })
    .environment(UserManager())
}

#Preview("Edit Mode") {
  EditRaceEditionView(
    mode: .edit,
    edition: RaceEdition.taipei2019,
    onCommit: { _ in },
    onDelete: {}
  )
  .environment(UserManager())
}
