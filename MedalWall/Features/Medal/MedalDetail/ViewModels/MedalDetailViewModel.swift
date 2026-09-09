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
  let isPersonalRecord: Bool
  private let repository = MedalFirestoreRepository()
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
    return .appLocalized("Division (\(division.displayName))")
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

  /// What the user wrote about the day, or nothing when they wrote only whitespace.
  var noteText: String? {
    guard let note = medal.note?.trimmingCharacters(in: .whitespacesAndNewlines),
      !note.isEmpty
    else { return nil }

    return note
  }

  /// Whether the user kept anything of the day — photos, a note, or both.
  var hasDay: Bool {
    !medal.eventPhotos.isEmpty || noteText != nil
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
