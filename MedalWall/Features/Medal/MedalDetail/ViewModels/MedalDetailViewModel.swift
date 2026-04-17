//
//  MedalDetailViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-12-24.
//

import SwiftUI
import SwiftData

@Observable
final class MedalDetailViewModel {
  // MARK: - Properties
  
  let gridSpacing: CGFloat = 10
  
  private var repository: MedalRepository?
  var medal: Medal
  
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
    guard let finishTime = medal.finishTime else { return "-- : -- : --" }
    return finishTime.formattedHMS
  }
  
  var averagePaceText: String {
    guard let pace = medal.averagePace else { return "--'-- \"" }
    let minutes = Int(pace)
    let seconds = Int((pace - Double(minutes)) * 60)
    return String(format: "%d'%02d\" /km", minutes, seconds)
  }
  
  var overallPlacementText: String {
    guard let placement = medal.overallPlacement else { return "--" }
    return "\(placement)"
  }
  
  var totalParticipantsText: String {
    guard let total = medal.totalParticipants else { return "" }
    return "of \(total)"
  }
  
  var divisionText: String {
    guard let division = medal.divisionEnum else { return "--" }
    return division.displayName
  }
  
  var divisionPlacementText: String {
    guard let placement = medal.divisionPlacement else { return "--" }
    return "\(placement)"
  }
  
  var divisionTotalText: String {
    guard let total = medal.divisionTotal else { return "" }
    return "of \(total)"
  }
  
  var genderPlacementText: String {
    guard let placement = medal.genderPlacement else { return "--" }
    return "\(placement)"
  }
  
  var genderTotalText: String {
    guard let total = medal.genderTotal else { return "" }
    return "of \(total)"
  }
  
  // MARK: - Functions
  
  func configure(context: ModelContext) {
    self.repository = MedalRepository(context: context)
  }
  
  func deleteMedal(_ medal: Medal) throws {
    guard let repository else { throw AppError.contextNotAttached }
    try repository.deleteMedal(medal)
    try repository.save()
  }
}
