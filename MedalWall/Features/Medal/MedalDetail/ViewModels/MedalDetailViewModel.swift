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
  let gridSpacing: CGFloat = 10
  private let emptyWithDash: String = "-"
  private let emptyString: String = ""
  private let repository = MedalFirestoreRepository()

  // MARK: - Init
  init(medal: Medal) {
    self.medal = medal
  }

  // MARK: - Computed
  var gridColumns: [GridItem] {
    [GridItem](
      repeating: GridItem(.flexible(minimum: 80), spacing: gridSpacing),
      count: 2
    )
  }

  var finishTimeText: String {
    guard let finishTime = medal.finishTime else { return emptyWithDash }
    return finishTime.formattedHMS
  }

  var averagePaceText: String {
    guard let pace = medal.averagePace else { return "--'-- \"" }
    let minutes = Int(pace)
    let seconds = Int((pace - Double(minutes)) * 60)
    return String(format: "%d'%02d\" /km", minutes, seconds)
  }

  var overallPlacementText: String {
    guard let placement = medal.overallPlacement else { return emptyWithDash }
    return "\(placement)"
  }

  var totalParticipantsText: String {
    guard let total = medal.totalParticipants else { return emptyString }
    return "of \(total)"
  }

  var divisionText: String {
    guard let division = medal.divisionEnum else { return emptyWithDash }
    return division.displayName
  }

  var divisionPlacementText: String {
    guard let placement = medal.divisionPlacement else { return emptyWithDash }
    return "\(placement)"
  }

  var divisionTotalText: String {
    guard let total = medal.divisionTotal else { return emptyString }
    return "of \(total)"
  }

  var genderPlacementText: String {
    guard let placement = medal.genderPlacement else { return emptyWithDash }
    return "\(placement)"
  }

  var genderTotalText: String {
    guard let total = medal.genderTotal else { return emptyString }
    return "of \(total)"
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
