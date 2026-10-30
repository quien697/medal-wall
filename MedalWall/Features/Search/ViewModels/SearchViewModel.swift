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
  /// Orders the medal fetches, so an older load's medals never replace a newer load's.
  private var medalLoads = LoadSequence()
  /// Orders the race fetches, for the same reason.
  private var raceLoads = LoadSequence()

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
    let medalLoad = medalLoads.begin()
    let raceLoad = raceLoads.begin()
    async let medalsLoaded: Void = loadMedals(userId: userId, load: medalLoad)
    await loadRaces(load: raceLoad)
    await medalsLoaded
  }

  /// Loads the user's medals, keeping the previous ones if the fetch fails. Its medals show
  /// unless a newer load's already have; only the newest load presents an error or counts as
  /// finished.
  private func loadMedals(userId: String?, load: Int) async {
    defer {
      if medalLoads.isNewest(load) { hasFinishedLoadingMedals = true }
    }
    guard let userId else { return }

    do {
      let fetched = try await medalRepository.fetchMedals(userId: userId)
      guard medalLoads.shouldApply(load) else { return }
      medals = fetched
    } catch {
      guard medalLoads.isNewest(load), self.error == nil else { return }
      self.error = .medalFetchFailed(error.localizedDescription)
    }
  }

  /// Loads every race, keeping the previous ones if the fetch fails. Its races show unless a
  /// newer load's already have; only the newest load presents an error or counts as finished.
  private func loadRaces(load: Int) async {
    defer {
      if raceLoads.isNewest(load) { hasFinishedLoadingRaces = true }
    }

    do {
      let fetched = try await raceRepository.fetchRaces()
      guard raceLoads.shouldApply(load) else { return }
      races = fetched
    } catch {
      guard raceLoads.isNewest(load), self.error == nil else { return }
      self.error = .raceFetchFailed(error.localizedDescription)
    }
  }
}
