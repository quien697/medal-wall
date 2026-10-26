//
//  SearchViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-10-25.
//

import Foundation

@Observable
final class SearchViewModel {
  // MARK: - Data
  var medals: [Medal] = []
  var races: [Race] = []

  // MARK: - State
  var error: AppError?
  /// Whether the medal fetch has finished at least once, succeeded or failed, so an empty
  /// section is known to be empty rather than not yet loaded.
  private(set) var hasFinishedLoadingMedals = false
  /// Whether the race fetch has finished at least once, succeeded or failed.
  private(set) var hasFinishedLoadingRaces = false

  // MARK: - Filter
  var searchText = ""

  // MARK: - Dependencies
  private let medalRepository: any MedalRepository
  private let raceRepository: any RaceRepository

  // MARK: - Init
  init(
    medalRepository: (any MedalRepository)? = nil,
    raceRepository: (any RaceRepository)? = nil
  ) {
    self.medalRepository = medalRepository ?? MedalFirestoreRepository()
    self.raceRepository = raceRepository ?? RaceFirestoreRepository()
  }

  // MARK: - Computed
  /// The field's text trimmed of whitespace and newlines.
  var query: String {
    searchText.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  var isQueryEmpty: Bool {
    query.isEmpty
  }

  /// The user's medals matching the query, most recent first.
  var matchingMedals: [Medal] {
    guard !isQueryEmpty else { return [] }
    return medals.matching(query)
  }

  /// The races matching the query, name matches first, each with `editionCount` clamped to
  /// zero or more: the count is maintained server-side, so a corrupt value must not reach a
  /// row and render as "-1 editions".
  var matchingRaces: [Race] {
    guard !isQueryEmpty else { return [] }
    return races.matching(query).map { race in
      var clamped = race
      clamped.editionCount = max(0, race.editionCount)
      return clamped
    }
  }

  /// The ids of record-holding medals, taken from the whole collection so a query never
  /// promotes a medal into a record.
  var personalRecordIDs: Set<String> {
    medals.personalRecordIDs
  }

  /// Whether either fetch has yet to finish for the first time.
  var isAwaitingFirstLoad: Bool {
    !hasFinishedLoadingMedals || !hasFinishedLoadingRaces
  }

  /// Whether to say nothing matches: only once both fetches have finished at least once, so
  /// it never flashes while data is still arriving. A reload leaves it showing.
  var isShowingNoResults: Bool {
    !isQueryEmpty && !isAwaitingFirstLoad && matchingMedals.isEmpty && matchingRaces.isEmpty
  }

  // MARK: - Functions
  /// Loads the user's medals and every race side by side, so either arrives without waiting
  /// on the other. With no signed-in user the medals are skipped.
  func load(userId: String?) async {
    async let medalLoad: Void = loadMedals(userId: userId)
    await loadRaces()
    await medalLoad
  }

  /// Loads the user's medals, keeping the previous ones if the fetch fails.
  private func loadMedals(userId: String?) async {
    defer { hasFinishedLoadingMedals = true }
    guard let userId else { return }

    do {
      medals = try await medalRepository.fetchMedals(userId: userId)
    } catch {
      self.error = .medalFetchFailed(error.localizedDescription)
    }
  }

  /// Loads every race, keeping the previous ones if the fetch fails.
  private func loadRaces() async {
    defer { hasFinishedLoadingRaces = true }

    do {
      races = try await raceRepository.fetchRaces()
    } catch {
      self.error = .raceFetchFailed(error.localizedDescription)
    }
  }
}
