//
//  StubRaceRepository.swift
//  MedalWall
//
//  Created by Quien on 2026-09-22.
//

import Foundation

@testable import MedalWall

/// Scriptable `RaceRepository` so race and edition flows can be tested without Firestore.
///
/// An `actor` for the same reason as `StubMedalRepository`. Edition writes move the stored
/// race's `editionCount` the way the Firestore implementation does, and a race update leaves
/// that count alone, so a test sees the count a caller would really end up with.
actor StubRaceRepository: RaceRepository {

  // MARK: - Script
  private(set) var races: [Race]
  /// Editions keyed by race id.
  private(set) var editions: [String: [RaceEdition]]
  private let fetchOutcome: Result<Void, AppError>
  /// Races whose editions fail to fetch while every other fetch follows `fetchOutcome`.
  private let failingEditionRaceIDs: Set<String>
  private let writeOutcome: Result<Void, AppError>
  private let deleteOutcome: Result<Void, AppError>

  // MARK: - Recorded calls
  private(set) var fetchCallCount = 0
  private(set) var createdRaces: [Race] = []
  private(set) var updatedRaces: [Race] = []
  private(set) var deletedRaceIDs: [String] = []
  private(set) var createdEditions: [RaceEdition] = []
  private(set) var updatedEditions: [RaceEdition] = []
  private(set) var deletedEditionIDs: [String] = []

  // MARK: - Init
  init(
    races: [Race] = [],
    editions: [String: [RaceEdition]] = [:],
    fetchOutcome: Result<Void, AppError> = .success(()),
    failingEditionRaceIDs: Set<String> = [],
    writeOutcome: Result<Void, AppError> = .success(()),
    deleteOutcome: Result<Void, AppError> = .success(())
  ) {
    self.races = races
    self.editions = editions
    self.fetchOutcome = fetchOutcome
    self.failingEditionRaceIDs = failingEditionRaceIDs
    self.writeOutcome = writeOutcome
    self.deleteOutcome = deleteOutcome
  }

  // MARK: - RaceRepository
  func fetchRaces() async throws -> [Race] {
    fetchCallCount += 1
    try fetchOutcome.get()
    return races
  }

  func fetchRace(id: String) async throws -> Race? {
    fetchCallCount += 1
    try fetchOutcome.get()
    return races.first { $0.id == id }
  }

  func createRace(_ race: Race) async throws {
    try writeOutcome.get()
    createdRaces.append(race)
    races.append(race)
  }

  func updateRace(_ race: Race) async throws {
    try writeOutcome.get()
    updatedRaces.append(race)
    guard let index = races.firstIndex(where: { $0.id == race.id }) else { return }
    let storedCount = races[index].editionCount
    var stored = race
    stored.editionCount = storedCount
    races[index] = stored
  }

  func deleteRace(id: String) async throws {
    try deleteOutcome.get()
    deletedRaceIDs.append(id)
    editions[id] = nil
    races.removeAll { $0.id == id }
  }

  func fetchEditions(raceId: String) async throws -> [RaceEdition] {
    fetchCallCount += 1
    try fetchOutcome.get()
    if failingEditionRaceIDs.contains(raceId) {
      throw AppError.raceFetchFailed("editions unavailable")
    }
    return editions[raceId] ?? []
  }

  func createEdition(_ edition: RaceEdition) async throws {
    try writeOutcome.get()
    createdEditions.append(edition)
    editions[edition.raceId, default: []].append(edition)
    moveEditionCount(raceId: edition.raceId, by: 1)
  }

  func updateEdition(_ edition: RaceEdition) async throws {
    try writeOutcome.get()
    updatedEditions.append(edition)
    guard let index = editions[edition.raceId]?.firstIndex(where: { $0.id == edition.id })
    else { return }
    editions[edition.raceId]?[index] = edition
  }

  func deleteEdition(raceId: String, editionId: String) async throws {
    try deleteOutcome.get()
    deletedEditionIDs.append(editionId)
    editions[raceId]?.removeAll { $0.id == editionId }
    moveEditionCount(raceId: raceId, by: -1)
  }

  // MARK: - Private Functions
  private func moveEditionCount(raceId: String, by delta: Int) {
    guard let index = races.firstIndex(where: { $0.id == raceId }) else { return }
    races[index].editionCount += delta
  }
}
