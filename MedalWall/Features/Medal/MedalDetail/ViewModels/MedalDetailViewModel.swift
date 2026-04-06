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
  private var repository: MedalRepository?
  var medal: Medal

  init(medal: Medal) {
    self.medal = medal
  }

  func configure(context: ModelContext) {
    self.repository = MedalRepository(context: context)
  }
  
  func deleteMedal(_ medal: Medal) throws {
    guard let repository else { throw AppError.contextNotAttached }
    
    try repository.deleteMedal(medal)
    try repository.save()
  }
}
