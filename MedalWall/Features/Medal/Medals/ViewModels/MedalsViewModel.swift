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
  /// Orders this screen's loads, so an older load's medals never replace a newer load's.
  private var loads = LoadSequence()

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

  /// Loads all medals for the given user from Firestore. Its medals show unless a newer load's
  /// already have, and only the newest load presents an error or ends loading.
  func loadMedals(userId: String) async {
    let load = loads.begin()
    isLoading = true
    defer {
      if loads.isNewest(load) { isLoading = false }
    }

    do {
      let fetched = try await repository.fetchMedals(userId: userId)
      guard loads.shouldApply(load) else { return }
      medals = fetched
      hasLoaded = true
    } catch {
      guard loads.isNewest(load) else { return }
      self.error = .medalFetchFailed(error.localizedDescription)
    }
  }
}
