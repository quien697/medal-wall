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
    guard let pace = medal.averagePace else { return "--'-- \"" }
    let minutes = Int(pace)
    let seconds = Int((pace - Double(minutes)) * 60)
    return String(format: "%d'%02d\" /km", minutes, seconds)
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
