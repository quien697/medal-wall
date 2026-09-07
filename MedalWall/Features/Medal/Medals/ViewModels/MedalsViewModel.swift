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
  var medals: [Medal] = []

  // MARK: - State
  var isLoading = false
  var error: AppError?

  // MARK: - Filter
  /// The distance the list is narrowed to.
  ///
  /// Resolved on read rather than reconciled on load: a medal can be deleted or have its
  /// distance edited elsewhere in the app, so a stored selection can name a category the
  /// collection no longer holds. Falling back here keeps the invariant true however the
  /// collection changed, with no reload hook to forget.
  var selectedFilter: MedalDistanceFilter {
    get {
      guard case .category(let category) = storedFilter else { return .all }
      let isStillOwned = medals.distanceCategoriesOwned.contains { $0.value == category.value }
      return isStillOwned ? storedFilter : .all
    }
    set { storedFilter = newValue }
  }

  private var storedFilter: MedalDistanceFilter = .all

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
