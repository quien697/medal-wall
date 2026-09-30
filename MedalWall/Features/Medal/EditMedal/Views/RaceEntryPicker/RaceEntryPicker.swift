//
//  RaceEntryPicker.swift
//  MedalWall
//
//  Created by Quien on 2026-04-14.
//

import SwiftUI

struct RaceEntryPicker: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss

  // MARK: - State
  @State private var viewModel: RaceEntryPickerViewModel
  @State private var selection: RaceEntry?
  @State private var errorWrapper: ErrorWrapper?

  // MARK: - Properties
  let onSelect: (RaceEntry) -> Void

  // MARK: - Init
  init(repository: (any RaceRepository)? = nil, onSelect: @escaping (RaceEntry) -> Void) {
    self._viewModel = State(initialValue: RaceEntryPickerViewModel(repository: repository))
    self.onSelect = onSelect
  }

  // MARK: - Body
  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        RaceEntrySubtitle(selection: selection)

        Divider()

        if viewModel.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if viewModel.races.isEmpty {
          ContentUnavailableView {
            Label("No Race Events", systemImage: "flag.fill")
              .font(.TypeScale.title2)
              .foregroundStyle(Color.Text.primary)
          } description: {
            Text("Add race events to use auto-fill")
              .font(.TypeScale.body)
              .foregroundStyle(Color.Text.secondary)
          }  // ContentUnavailableView
        } else {
          RaceEntryList(
            races: viewModel.races, editions: viewModel.editions, selection: $selection)
        }
      }
      .navigationTitle("Pick Race Entry")
      .navigationBarTitleDisplayMode(.inline)
      .task {
        await viewModel.load()
      }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .cancel) {
            dismiss()
          }
        }

        if let selection {
          ToolbarItem(placement: .confirmationAction) {
            Button(role: .confirm) {
              onSelect(selection)
              dismiss()
            }
          }
        }
      }  // toolbar
      .onChange(of: viewModel.error) { _, error in
        if let error {
          errorWrapper = ErrorWrapper(error: error)
        }
      }
      .sheet(
        item: $errorWrapper,
        onDismiss: { viewModel.error = nil },
        content: { wrapper in
          ErrorView(errorWrapper: wrapper)
        }
      )
    }  // NavigationStack
  }
}

#Preview {
  RaceEntryPicker { _ in }
}
