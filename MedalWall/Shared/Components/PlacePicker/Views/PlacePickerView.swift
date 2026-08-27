//
//  PlacePickerView.swift
//  MedalWall
//
//  Created by Quien on 2026-08-05.
//

import SwiftUI

struct PlacePickerView: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss
  // MARK: - State
  @State private var viewModel: PlacePickerViewModel
  @State private var errorWrapper: ErrorWrapper?
  // MARK: - Properties
  private let onSelect: (Place) -> Void

  // MARK: - Init
  init(
    viewModel: PlacePickerViewModel? = nil,
    onSelect: @escaping (Place) -> Void
  ) {
    _viewModel = State(initialValue: viewModel ?? PlacePickerViewModel())
    self.onSelect = onSelect
  }

  // MARK: - Body
  var body: some View {
    NavigationStack {
      List {
        switch viewModel.status {
        case .results(let suggestions):
          ForEach(suggestions) { suggestion in
            Button {
              Task { await viewModel.select(suggestion) }
            } label: {
              VStack(alignment: .leading, spacing: 2) {
                Text(suggestion.title)
                  .foregroundStyle(Color.Text.primary)
                Text(suggestion.subtitle)
                  .font(.caption)
                  .foregroundStyle(Color.Text.secondary)
              }  // VStack
            }  // Button
          }  // ForEach

        case .searching:
          HStack {
            Spacer()
            ProgressView()
            Spacer()
          }  // HStack
          .listRowBackground(Color.clear)

        case .idle, .noResults:
          EmptyView()
        }
      }  // List
      .overlay {
        if viewModel.status == .noResults {
          ContentUnavailableView.search(text: viewModel.query)
        }
      }
      .searchable(text: $viewModel.query, prompt: "Search for a city or place")
      .navigationTitle("place")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
      }
      .onChange(of: viewModel.query) {
        viewModel.search()
      }
      .onChange(of: viewModel.isFinished) { _, isFinished in
        guard isFinished, let place = viewModel.selectedPlace else { return }
        onSelect(place)
        dismiss()
      }
      .onChange(of: viewModel.error) { _, error in
        if let error {
          errorWrapper = ErrorWrapper(error: error)
        }
      }
      .sheet(
        item: $errorWrapper,
        onDismiss: { viewModel.error = nil },
        content: { ErrorView(errorWrapper: $0) }
      )
    }  // NavigationStack
  }
}

#if DEBUG
  /// Scripted service so each preview can show one distinct state.
  @MainActor
  private final class PreviewPlaceSearchService: PlaceSearchService {
    enum Mode { case results, empty, failure }

    private let mode: Mode

    init(_ mode: Mode) {
      self.mode = mode
    }

    func suggestions(for query: String) -> AsyncThrowingStream<[PlaceSuggestion], any Error> {
      let (stream, continuation) = AsyncThrowingStream<[PlaceSuggestion], any Error>.makeStream()
      switch mode {
      case .results:
        continuation.yield([
          PlaceSuggestion(id: "0", title: "Taipei City", subtitle: "Taiwan"),
          PlaceSuggestion(id: "1", title: "Fuxing District", subtitle: "Taoyuan, Taiwan"),
          PlaceSuggestion(id: "2", title: "Vancouver", subtitle: "British Columbia, Canada")
        ])
        continuation.finish()
      case .empty:
        continuation.yield([])
        continuation.finish()
      case .failure:
        continuation.finish(throwing: AppError.placeSearchFailed("Preview failure"))
      }
      return stream
    }

    func resolve(suggestionID: PlaceSuggestion.ID) async throws -> Place {
      Place(countryCode: "TW", city: "Taipei City")
    }
  }

  private struct PlacePickerPreview: View {
    @State private var viewModel: PlacePickerViewModel

    init(_ mode: PreviewPlaceSearchService.Mode) {
      _viewModel = State(
        initialValue: PlacePickerViewModel(
          service: PreviewPlaceSearchService(mode), debounce: .zero))
    }

    var body: some View {
      PlacePickerView(viewModel: viewModel) { _ in }
        .task {
          viewModel.query = "tai"
          viewModel.search()
          await viewModel.searchTask?.value
        }
    }
  }
#endif

#Preview("Results") {
  PlacePickerPreview(.results)
}

#Preview("No results") {
  PlacePickerPreview(.empty)
}

#Preview("Error") {
  PlacePickerPreview(.failure)
}
