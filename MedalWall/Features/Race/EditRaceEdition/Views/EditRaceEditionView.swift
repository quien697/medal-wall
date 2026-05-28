//
//  EditRaceEditionView.swift
//  MedalWall
//
//  Created by Quien on 2026-03-24.
//

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
  private let onCommit: ((DraftRaceEdition) -> Void)?
  private let onDelete: (() -> Void)?

  // MARK: - Init
  init(
    mode: ItemEditMode,
    raceId: String,
    edition: RaceEdition? = nil,
    onCommit: ((DraftRaceEdition) -> Void)? = nil,
    onDelete: (() -> Void)? = nil
  ) {
    self._viewModel = State(
      initialValue: EditRaceEditionViewModel(mode: mode, raceId: raceId, edition: edition))
    self.onCommit = onCommit
    self.onDelete = onDelete
  }

  // MARK: - Body
  var body: some View {
    NavigationStack {
      VStack {
        EditPhotoPicker(
          photo: viewModel.photo,
          hint: viewModel.photoHint,
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
              }
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
          if viewModel.isLoading {
            ProgressView()
          } else {
            Button(role: .confirm) {
              if let onCommit {
                let draft = viewModel.buildDraft(userId: userManager.currentUserID ?? "")
                onCommit(draft)
                dismiss()
              } else {
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
            }
            .disabled(!viewModel.isFormValid)
          }
        }  // ToolbarItem
      }  // toolbar
      .task {
        await viewModel.loadExistingPhoto()
      }
      .alert(isPresented: $isPresentingDeleteConfirm) {
        .deleteConfirmation(name: "Edition") {
          if let onDelete {
            onDelete()
            dismiss()
          } else {
            Task {
              await viewModel.deleteEdition()
              if viewModel.error == nil { dismiss() }
            }
          }
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
      .onChange(of: viewModel.error) { _, error in
        if let error { errorWrapper = ErrorWrapper(error: error) }
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
        AddDistanceView { newDistance in
          do {
            try viewModel.addDistance(newDistance)
          } catch let appError as AppError {
            errorWrapper = ErrorWrapper(error: appError)
          } catch {
            errorWrapper = ErrorWrapper(error: AppError.unknown)
          }
        }
        .presentationDetents([.medium])
      }
      .sheet(
        item: $errorWrapper,
        onDismiss: { viewModel.error = nil },
        content: { wrapper in
          ErrorView(errorWrapper: wrapper)
        }
      )  // sheet
    }  // NavigationStack
  }
}

#Preview("Add Mode") {
  EditRaceEditionView(mode: .add, raceId: "preview-race-id")
    .environment(UserManager())
}

#Preview("Edit Mode") {
  EditRaceEditionView(
    mode: .edit,
    raceId: RaceEdition.sampleData.first!.raceId,
    edition: RaceEdition.sampleData.first!
  )
  .environment(UserManager())
}
