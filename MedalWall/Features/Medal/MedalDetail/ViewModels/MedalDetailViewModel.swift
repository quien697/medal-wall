//
//  MedalDetailViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-12-24.
//

import SwiftUI

@Observable
final class MedalDetailViewModel {
  // MARK: - Properties
  var medal: Medal
  /// Whether this medal holds its distance's personal record.
  ///
  /// Supplied by whatever opened the screen rather than derived here: a record is a
  /// property of the whole collection, and this screen is presented one medal.
  let isPersonalRecord: Bool
  private let repository = MedalFirestoreRepository()

  /// What an unrecorded field reads as. One glyph across every result field but the
  /// finish time, which is large enough to say it in words.
  private static let unfilled = "—"

  // MARK: - Init
  init(medal: Medal, isPersonalRecord: Bool = false) {
    self.medal = medal
    self.isPersonalRecord = isPersonalRecord
  }

  // MARK: - Computed
  /// The finish time, or the same wording the collection list uses for an untimed medal.
  var finishTimeText: String {
    guard let finishTime = medal.finishTime else { return .appLocalized("No time recorded") }
    return finishTime.formattedHMS
  }

  /// The pace without its unit, so the screen can set the two at different sizes.
  var averagePaceValue: String {
    DistanceUnit.resolved().paceValueText(minutesPerKilometer: medal.averagePace)
      ?? Self.unfilled
  }

  /// The unit the pace is expressed in, absent when there is no pace to qualify.
  var averagePaceUnit: String? {
    let unit = DistanceUnit.resolved()
    guard unit.paceValueText(minutesPerKilometer: medal.averagePace) != nil else { return nil }

    return "/\(unit.abbreviation())"
  }

  var distanceText: String {
    Self.heroDistanceText(for: medal.distance.category, in: DistanceUnit.resolved())
  }

  /// The hero's distance line. A preset pairs its name with the measurement
  /// (`Full · 26.2 mi`); a custom distance already *is* the measurement, so it is shown
  /// once rather than repeated.
  nonisolated static func heroDistanceText(
    for category: RaceDistanceCategory,
    in unit: DistanceUnit,
    defaults: UserDefaults = .standard
  ) -> String {
    let label = category.label(in: unit, defaults: defaults)
    if case .custom = category { return label }

    return "\(label) · \(unit.formatted(kilometers: category.value, defaults: defaults))"
  }

  var overallPlacementText: String {
    Self.placementText(medal.overallPlacement)
  }

  var overallTotalText: String? {
    Self.totalText(medal.totalParticipants, placement: medal.overallPlacement)
  }

  /// The division field's label, naming the group the placement was run within so the two
  /// read as one fact rather than two measurements.
  var divisionLabel: String {
    guard let division = medal.divisionEnum else { return .appLocalized("Division") }
    return "\(String.appLocalized("Division")) \(division.displayName)"
  }

  var divisionPlacementText: String {
    Self.placementText(medal.divisionPlacement)
  }

  var divisionTotalText: String? {
    Self.totalText(medal.divisionTotal, placement: medal.divisionPlacement)
  }

  var genderPlacementText: String {
    Self.placementText(medal.genderPlacement)
  }

  var genderTotalText: String? {
    Self.totalText(medal.genderTotal, placement: medal.genderPlacement)
  }

  // MARK: - Functions
  /// A placement, or the unfilled marker when it was never recorded.
  private static func placementText(_ placement: Int?) -> String {
    guard let placement else { return unfilled }
    return "\(placement)"
  }

  /// The field a placement ran against, absent unless there is a placement to qualify.
  ///
  /// A total on its own would read as `— / 7373`, stating the size of a field the medal
  /// never records a position in.
  private static func totalText(_ total: Int?, placement: Int?) -> String? {
    guard let total, placement != nil else { return nil }
    return "/ \(total)"
  }

  /// Reloads the medal from Firestore and updates the local state.
  func reloadMedal() async {
    guard let updated = try? await repository.fetchMedal(id: medal.id, userId: medal.userID) else {
      return
    }
    medal = updated
  }

  /// Deletes the medal from Firestore.
  func deleteMedal(_ medal: Medal) async throws {
    try await repository.deleteMedal(id: medal.id, userId: medal.userID)
  }
}
