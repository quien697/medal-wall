//
//  MedalRepository.swift
//  MedalWall
//
//  Created by Quien on 2025-12-23.
//

import Foundation
import SwiftData

final class MedalRepository {
  private(set) var context: ModelContext?
  
  init(context: ModelContext? = nil) {
    self.context = context
  }
  
  func configure(context: ModelContext) {
    self.context = context
  }
  
  func save() throws {
    guard let context else { throw AppError.contextNotAttached }
    try context.save()
  }
  
  func insertMedal(_ medal: Medal) throws {
    guard let context else { throw AppError.contextNotAttached }
    context.insert(medal)
  }
  
  func deleteMedal(_ medal: Medal) throws {
    guard let context else { throw AppError.contextNotAttached }
    context.delete(medal)
  }

  func insertEventPhoto(_ photo: EventPhoto) throws {
    guard let context else { throw AppError.contextNotAttached }
    context.insert(photo)
  }

  func deleteEventPhoto(_ photo: EventPhoto) throws {
    guard let context else { throw AppError.contextNotAttached }
    context.delete(photo)
  }
}
