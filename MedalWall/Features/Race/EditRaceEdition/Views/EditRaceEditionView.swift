//
//  EditRaceEditionView.swift
//  MedalWall
//
//  Created by Quien on 2026-03-24.
//

import CropImage
import SwiftUI

struct EditRaceEditionView: View {
  // MARK: - Environment
  @Environment(UserManager.self) private var userManager
  @Environment(\.dismiss) private var dismiss

  // MARK: - State
  @State private var isPresentingAddDistance = false
  @State private var isPresentingDeleteConfirm = false
  @State private var errorWrapper: ErrorWrapper?
  @State private var viewModel: EditRaceEditionViewModel

  // MARK: - Properties
  private let onCommit: (DraftRaceEdition) -> Void
  private let onDelete: (() -> Void)?

  // MARK: - Init
  /// Opens the editor on a new edition, handed to `onCommit` when confirmed.
  init(onCommit: @escaping (DraftRaceEdition) -> Void) {
    self._viewModel = State(initialValue: EditRaceEditionViewModel(mode: .add, draft: nil))
    self.onCommit = onCommit
    self.onDelete = nil
  }

  /// Opens the editor on a staged edition: `onCommit` receives the edited draft, and `onDelete`
  /// runs when the user confirms deleting it.
  init(
    editing draft: DraftRaceEdition,
    onCommit: @escaping (DraftRaceEdition) -> Void,
    onDelete: @escaping () -> Void
  ) {
    self._viewModel = State(initialValue: EditRaceEditionViewModel(mode: .edit, draft: draft))
    self.onCommit = onCommit
    self.onDelete = onDelete
  }

  // MARK: - Body
  var body: some View {
    NavigationStack {
      VStack {
        PhotoSlot(
          content: viewModel.photo.content,
          imageType: .raceHero,
          cropShape: .square,
          title: "Edition photo",
          message: "Leave it empty to use the race logo.",
          onPick: { viewModel.photo.update(with: $0) },
          onRemove: { viewModel.photo.remove() },
          onError: { errorWrapper = ErrorWrapper(error: $0) },
          onCheckingChange: { viewModel.photoChecks.changed(isChecking: $0) }
        )  // PhotoSlot

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
          }  // Button
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
          }  // Button
          .disabled(!viewModel.canSave)
        }  // ToolbarItem
      }  // toolbar
      .interactiveDismissDisabled()
      .task {
        await viewModel.loadStoredPhoto()
      }
      .alert(isPresented: $isPresentingDeleteConfirm) {
        .deleteConfirmation(.edition(year: viewModel.originalYear)) {
          onDelete?()
          dismiss()
        }
      }
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
  EditRaceEditionView(onCommit: { _ in })
    .environment(UserManager())
}

#Preview("Edit Mode") {
  EditRaceEditionView(
    editing: DraftRaceEdition(from: .taipei2019),
    onCommit: { _ in },
    onDelete: {}
  )
  .environment(UserManager())
}
