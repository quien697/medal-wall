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
  var isLoading = false
  var error: AppError?

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
  private let repository = MedalFirestoreRepository()

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

  // MARK: - Functions
  /// How many medals `distanceFilter` selects.
  func count(for distanceFilter: MedalDistanceFilter) -> Int {
    medals.count(for: distanceFilter)
  }

  /// Falls a stored category selection back to `.all` if the collection no longer
  /// owns it. Called whenever `medals` or `selectedFilter` changes.
  private func reconcileFilter() {
    guard case .category(let category) = selectedFilter else { return }
    if !medals.distanceCategoriesOwned.contains(where: { $0.value == category.value }) {
      selectedFilter = .all
    }
  }

  /// Loads all medals for the given user from Firestore.
  func loadMedals(userId: String) async {
    defer { isLoading = false }
    isLoading = true

    do {
      medals = try await repository.fetchMedals(userId: userId)
    } catch {
      self.error = .medalFetchFailed(error.localizedDescription)
    }
  }
}
