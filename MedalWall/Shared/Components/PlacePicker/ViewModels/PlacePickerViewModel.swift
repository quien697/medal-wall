//
//  PlacePickerViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-08-05.
//

import Foundation

@Observable
@MainActor
final class PlacePickerViewModel {
  // MARK: - Data
  var query: String = ""
  private(set) var suggestions: [PlaceSuggestion] = []
  private(set) var selectedPlace: Place?

  // MARK: - State
  private(set) var isSearching = false
  /// Set once a suggestion resolves, so the presenting view can dismiss.
  private(set) var isFinished = false
  var error: AppError?
  private var hasSearched = false

  /// The in-flight debounced search. Exposed so callers — and tests — can await it.
  @ObservationIgnored private(set) var searchTask: Task<Void, Never>?

  // MARK: - Dependencies
  private let service: any PlaceSearchService
  private let debounce: Duration

  // MARK: - Init
  /// The service is built here rather than as a default argument: default expressions are
  /// evaluated in a nonisolated context, which cannot construct a `@MainActor` service.
  init(
    service: (any PlaceSearchService)? = nil,
    debounce: Duration = .milliseconds(300)
  ) {
    self.service = service ?? MapKitPlaceSearchService()
    self.debounce = debounce
  }

  // MARK: - Computed
  /// Whether to show the "nothing matched" state. A failed search is not an empty result,
  /// so an error suppresses it — otherwise a dropped connection would read as "no such place".
  var hasNoResults: Bool {
    hasSearched && suggestions.isEmpty && !isSearching && error == nil
  }

  // MARK: - Functions
  /// Debounces the current `query` and searches for it, replacing any search in flight.
  func search() {
    searchTask?.cancel()

    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else {
      suggestions = []
      hasSearched = false
      error = nil
      searchTask = nil
      return
    }

    searchTask = Task { [weak self, debounce] in
      try? await Task.sleep(for: debounce)
      guard !Task.isCancelled else { return }
      await self?.runSearch(trimmed)
    }
  }

  /// Resolves `suggestion` into a place, leaving the current selection untouched on
  /// failure so a failed lookup never silently changes what will be saved.
  func select(_ suggestion: PlaceSuggestion) async {
    do {
      selectedPlace = try await service.resolve(suggestionID: suggestion.id)
      isFinished = true
    } catch let appError as AppError {
      error = appError
    } catch {
      self.error = .placeNotResolved
    }
  }

  /// Consumes the suggestion stream until it finishes or a newer query supersedes it.
  private func runSearch(_ text: String) async {
    isSearching = true
    error = nil
    defer { isSearching = false }

    do {
      for try await results in service.suggestions(for: text) {
        suggestions = results
        hasSearched = true
        isSearching = false
      }
    } catch is CancellationError {
      // Superseded by a newer query — not a failure worth showing.
    } catch let appError as AppError {
      error = appError
    } catch {
      self.error = .placeSearchFailed(error.localizedDescription)
    }
  }
}
