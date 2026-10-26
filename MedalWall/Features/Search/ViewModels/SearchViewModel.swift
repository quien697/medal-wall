//
//  SearchViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-10-25.
//

import Foundation

/// `@MainActor` spelled out: the app target already defaults to it, but this file is also compiled
/// into the test module, which doesn't, and its two fetches run side by side writing `error`.
@MainActor
@Observable
final class SearchViewModel {
  // MARK: - Data
  var medals: [Medal] = []
  var races: [Race] = []

  // MARK: - State
  /// The first failure since the error sheet was last dismissed. A later failure leaves it
  /// alone: a new value would make the sheet close and reopen with the other error.
  var error: AppError?
  /// Whether the medal fetch has finished at least once, succeeded or failed, so an empty
  /// section is known to be empty rather than not yet loaded. Only the newest load counts.
  private(set) var hasFinishedLoadingMedals = false
  /// Whether the race fetch has finished at least once, succeeded or failed.
  private(set) var hasFinishedLoadingRaces = false
  /// Numbers each load, so a fetch that returns after a newer load has started leaves the
  /// newer load's data, errors and finished flags alone. Loads are never cancelled, so they
  /// can overlap.
  private var loadGeneration = 0

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
  /// zero or more.
  var matchingRaces: [Race] {
    guard !isQueryEmpty else { return [] }
    return races.matching(query).withClampedEditionCounts
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
    loadGeneration += 1
    let generation = loadGeneration
    async let medalLoad: Void = loadMedals(userId: userId, generation: generation)
    await loadRaces(generation: generation)
    await medalLoad
  }

  /// Loads the user's medals, keeping the previous ones if the fetch fails. A load that is no
  /// longer the newest changes nothing.
  private func loadMedals(userId: String?, generation: Int) async {
    defer {
      if generation == loadGeneration { hasFinishedLoadingMedals = true }
    }
    guard let userId else { return }

    do {
      let fetched = try await medalRepository.fetchMedals(userId: userId)
      guard generation == loadGeneration else { return }
      medals = fetched
    } catch {
      guard generation == loadGeneration, self.error == nil else { return }
      self.error = .medalFetchFailed(error.localizedDescription)
    }
  }

  /// Loads every race, keeping the previous ones if the fetch fails. A load that is no longer
  /// the newest changes nothing.
  private func loadRaces(generation: Int) async {
    defer {
      if generation == loadGeneration { hasFinishedLoadingRaces = true }
    }

    do {
      let fetched = try await raceRepository.fetchRaces()
      guard generation == loadGeneration else { return }
      races = fetched
    } catch {
      guard generation == loadGeneration, self.error == nil else { return }
      self.error = .raceFetchFailed(error.localizedDescription)
    }
  }
}
