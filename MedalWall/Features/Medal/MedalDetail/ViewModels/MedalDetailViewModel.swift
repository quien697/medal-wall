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
  private let repository = MedalFirestoreRepository()

  // MARK: - Init
  init(medal: Medal) {
    self.medal = medal
  }

  // MARK: - Computed
  var finishTimeText: String {
    guard let finishTime = medal.finishTime else { return "-" }
    return finishTime.formattedHMS
  }

  var averagePaceText: String {
    Self.paceText(minutesPerKilometer: medal.averagePace, in: DistanceUnit.resolved())
  }

  var distanceText: String {
    Self.heroDistanceText(for: medal.distance.category, in: DistanceUnit.resolved())
  }

  /// A pace in minutes per kilometre, rendered per the given unit — `5'41" /km` or
  /// `9'08" /mi`. Seconds are truncated, which is the app's long-standing behaviour.
  nonisolated static func paceText(
    minutesPerKilometer pace: Double?,
    in unit: DistanceUnit,
    defaults: UserDefaults = .standard
  ) -> String {
    guard let pace else { return "--'-- \"" }
    let converted = unit.pace(fromMinutesPerKilometer: pace)
    let minutes = Int(converted)
    let seconds = Int((converted - Double(minutes)) * 60)

    return String(
      format: "%d'%02d\" /%@", minutes, seconds, unit.abbreviation(defaults: defaults))
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
    guard let placement = medal.overallPlacement else { return "-" }
    return "\(placement)"
  }

  var totalParticipantsText: String {
    guard let total = medal.totalParticipants else { return "" }
    return .appLocalized("of \(String(total))")
  }

  var divisionText: String {
    guard let division = medal.divisionEnum else { return "-" }
    return division.displayName
  }

  var divisionPlacementText: String {
    guard let placement = medal.divisionPlacement else { return "-" }
    return "\(placement)"
  }

  var divisionTotalText: String {
    guard let total = medal.divisionTotal else { return "" }
    return .appLocalized("of \(String(total))")
  }

  var genderPlacementText: String {
    guard let placement = medal.genderPlacement else { return "-" }
    return "\(placement)"
  }

  var genderTotalText: String {
    guard let total = medal.genderTotal else { return "" }
    return .appLocalized("of \(String(total))")
  }

  // MARK: - Functions
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
