//
//  MedalsViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-04-03.
//

import SwiftUI

@Observable
final class MedalsViewModel {
  // MARK: - Data
  var medals: [Medal] = [] {
    didSet { reconcileFilter() }
  }

  // MARK: - State
  /// Starts `true`: the screen loads as soon as it appears, and until then an empty
  /// collection is not yet known to be empty.
  var isLoading = true
  /// Whether a load has succeeded, so a reload keeps the collection on screen.
  private(set) var hasLoaded = false
  var error: AppError?
  /// Numbers each load, so a fetch that returns after a newer load has started leaves the
  /// newer load's medals, error and loading state alone. Loads are never cancelled, so they can
  /// overlap.
  private var loadGeneration = 0

  // MARK: - Filter
  /// The distance the list is narrowed to.
  ///
  /// A stored property so the `@Bindable` projected value and `@Observable` write
  /// tracking work directly. Reconciles on `medals` change so a deleted medal can
  /// never leave the selection naming a category the collection no longer holds.
  var selectedFilter: MedalDistanceFilter = .all {
    didSet { reconcileFilter() }
  }

  // MARK: - Dependencies
  private let repository: any MedalRepository

  // MARK: - Init
  init(repository: (any MedalRepository)? = nil) {
    self.repository = repository ?? MedalFirestoreRepository()
  }

  // MARK: - Computed
  /// `All` followed by one option per distance the user owns, longest first.
  ///
  /// Derived from the collection, so every option selects at least one medal and an empty
  /// collection offers none.
  var availableFilters: [MedalDistanceFilter] {
    guard !medals.isEmpty else { return [] }
    return [.all] + medals.distanceCategoriesOwned.map { .category($0) }
  }

  /// The selected medals split into year groups, most recent year first.
  var yearGroups: [MedalYearGroup] {
    medals.filtered(by: selectedFilter).groupedByYear
  }

  /// The ids of record-holding medals, taken from the whole collection so a filter
  /// selection never promotes a medal into a record.
  var personalRecordIDs: Set<String> {
    medals.personalRecordIDs
  }

  var isEmpty: Bool {
    medals.isEmpty
  }

  /// Bones stand in for the collection while it loads, until a load first succeeds.
  var isShowingSkeleton: Bool {
    isLoading && !hasLoaded
  }

  // MARK: - Functions
  /// Falls a stored category selection back to `.all` if the collection no longer
  /// owns it. Called whenever `medals` or `selectedFilter` changes.
  private func reconcileFilter() {
    guard case .category(let category) = selectedFilter else { return }
    if !medals.distanceCategoriesOwned.contains(category) {
      selectedFilter = .all
    }
  }

  /// Loads all medals for the given user from Firestore. A load that is no longer the newest
  /// changes nothing.
  func loadMedals(userId: String) async {
    loadGeneration += 1
    let generation = loadGeneration
    isLoading = true
    defer {
      if generation == loadGeneration { isLoading = false }
    }

    do {
      let fetched = try await repository.fetchMedals(userId: userId)
      guard generation == loadGeneration else { return }
      medals = fetched
      hasLoaded = true
    } catch {
      guard generation == loadGeneration else { return }
      self.error = .medalFetchFailed(error.localizedDescription)
    }
  }
}
