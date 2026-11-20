//
//  EditRaceView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import CropImage
import SwiftUI

struct EditRaceView: View {
  // MARK: - Environment
  @Environment(UserManager.self) private var userManager
  @Environment(\.dismiss) private var dismiss

  // MARK: - State
  @State private var viewModel: EditRaceViewModel
  @State private var errorWrapper: ErrorWrapper?
  @State private var isPresentingAddEdition = false
  @State private var isPresentingPlacePicker = false
  @State private var selectedEdition: DraftRaceEdition?

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
        PhotoSlot(
          content: viewModel.photo.content,
          imageType: .raceHero,
          cropShape: .square,
          title: "Race logo",
          onPick: { viewModel.photo.update(with: $0) },
          onRemove: { viewModel.photo.remove() },
          onError: { errorWrapper = ErrorWrapper(error: $0) },
          onCheckingChange: { viewModel.photoChecks.changed(isChecking: $0) }
        )  // PhotoSlot
        .frame(maxWidth: .infinity)
        .listRowBackground(Color.clear)

        EditRaceInfoSection(
          name: $viewModel.name,
          url: $viewModel.websiteUrl,
          place: viewModel.place,
          onEditPlace: {
            isPresentingPlacePicker = true
          }
        )

        if viewModel.mode == .edit, viewModel.raceId != nil {
          EditRaceEditionSection(
            editions: viewModel.displayedEditions,
            isShowingSkeleton: viewModel.isShowingEditionsSkeleton,
            namespace: namespace,
            transitionID: addEdition,
            canAddEdition: viewModel.canAddEdition,
            onTapAddEdition: { isPresentingAddEdition = true },
            onTapEdition: { selectedEdition = $0 },
            onDelete: viewModel.stageDeleteEdition
          )
        }
      }  // Form
      .navigationTitle("\(viewModel.mode.displayName) Race")
      .navigationBarTitleDisplayMode(.inline)
      .scrollContentBackground(.hidden)
      .background(Color.Background.primary)
      .disabled(viewModel.isLoading)
      .task {
        await viewModel.load()
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .cancel) {
            dismiss()
          }  // Button
          .disabled(viewModel.isLoading)
        }  // ToolbarItem

        ToolbarItem(placement: .confirmationAction) {
          if viewModel.isLoading {
            ProgressView()
          } else {
            Button(role: .confirm) {
              guard let userId = userManager.currentUserID else {
                errorWrapper = ErrorWrapper(error: AppError.notSignedIn)
                return
              }
              Task {
                await viewModel.save(by: userId)
                if viewModel.error == nil {
                  dismiss()
                }
              }
            }  // Button
            .disabled(!viewModel.canSave)
          }
        }  // ToolbarItem
      }  // toolbar
      .interactiveDismissDisabled()
      .onChange(of: viewModel.error) { _, error in
        if let error {
          errorWrapper = ErrorWrapper(error: error)
        }
      }
      .sheet(isPresented: $isPresentingPlacePicker) {
        PlacePickerView { viewModel.place = $0 }
      }
      .sheet(isPresented: $isPresentingAddEdition) {
        AddRaceEditionView(
          onCommit: { draft in
            viewModel.stageAddEdition(draft)
          }
        )
        .navigationTransition(.zoom(sourceID: addEdition, in: namespace))
      }
      .sheet(item: $selectedEdition) { draft in
        EditRaceEditionView(
          editing: draft,
          onCommit: { updatedDraft in
            viewModel.stageUpdateEdition(updatedDraft)
          },
          onDelete: {
            viewModel.stageDeleteEdition(id: draft.id)
          }
        )
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
  EditRaceView(mode: .edit, race: Race.taipei)
    .environment(UserManager())
}
