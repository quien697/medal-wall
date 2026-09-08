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

  /// The record at each distance that has one, longest distance first.
  ///
  /// Reads `medals` rather than the filtered set: the carousel describes the collection,
  /// not the current view of it, so selecting a distance narrows the list beneath it and
  /// leaves the cards alone.
  var personalBests: [MedalPersonalBest] {
    medals.personalBests
  }

  var isEmpty: Bool {
    medals.isEmpty
  }

  // MARK: - Functions
  /// How many medals `distanceFilter` selects.
  func count(for distanceFilter: MedalDistanceFilter) -> Int {
    medals.count(for: distanceFilter)
  }

  /// The distance a record was set at, in the user's chosen unit.
  func distanceText(for personalBest: MedalPersonalBest) -> String {
    personalBest.category.description
  }

  /// The race a record was set at.
  func raceNameText(for personalBest: MedalPersonalBest) -> String {
    personalBest.medal.name
  }

  /// The record time. A personal best is only ever built from a medal with an eligible
  /// time, so the placeholder is unreachable rather than a state the card can show.
  func finishTimeText(for personalBest: MedalPersonalBest) -> String {
    personalBest.medal.finishTime?.formattedHMS ?? "-"
  }

  /// The pace that record time represents, in the user's chosen unit.
  func paceText(for personalBest: MedalPersonalBest) -> String {
    MedalDetailViewModel.paceText(
      minutesPerKilometer: personalBest.medal.averagePace,
      in: DistanceUnit.resolved()
    )
  }

  /// The zoom transition source for a record's card.
  ///
  /// Prefixed because the same medal's row very likely declares
  /// `matchedTransitionSource(id: medal.id)` further down the screen, and two sources
  /// sharing an id in one namespace leave the transition with no way to choose.
  func transitionID(for personalBest: MedalPersonalBest) -> String {
    "personalBest-\(personalBest.medal.id)"
  }

  /// Which card a scroll position is showing, for the dots the card draws.
  ///
  /// `scrollPosition` reports `nil` until the first scroll, and a stored position can name
  /// a distance the collection no longer holds. Both resolve to the first card rather than
  /// to no card at all, which would leave every dot dimmed.
  func personalBestPage(forScrolledID scrolledID: MedalPersonalBest.ID?) -> Int {
    guard let scrolledID,
      let page = personalBests.firstIndex(where: { $0.id == scrolledID })
    else { return 0 }

    return page
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
