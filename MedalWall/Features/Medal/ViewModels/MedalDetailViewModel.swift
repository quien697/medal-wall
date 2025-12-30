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
  private let repository: MedalRepository
  var medal: Medal

  init(medal: Medal, repository: MedalRepository = MedalRepository()) {
    self.medal = medal
    self.repository = repository
  }

  func attachContext(_ context: ModelContext) throws {
    repository.attachContext(context)
  }

  func deleteMedal(_ medal: Medal) throws {
    try repository.deleteMedal(medal)
    try repository.save()
  }
}
