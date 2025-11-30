//
//  RaceRepository.swift
//  MedalWall
//
//  Created by Quien on 2025-11-29.
//

import Foundation
import SwiftData

final class RaceRepository {
  private(set) var context: ModelContext?
  
  init(context: ModelContext? = nil) {
    self.context = context
  }
  
  func attachContext(_ context: ModelContext) {
    self.context = context
  }
  
  func save() throws {
    guard let context else { throw AppError.contextNotAttached }
    try context.save()
  }
  
  // MARK: - Race
  func insertRace(_ race: Race) throws {
    guard let context else { throw AppError.contextNotAttached }
    context.insert(race)
  }
  
  func deleteRace(_ race: Race) throws {
    guard let context else { throw AppError.contextNotAttached }
    context.delete(race)
  }
  
  // MARK: - Race Category
  func deleteCategory(_ category: RaceCategory) throws {
    guard let context else { throw AppError.contextNotAttached }
    context.delete(category)
  }
}
