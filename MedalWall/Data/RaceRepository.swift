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
  
  func configure(context: ModelContext) {
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
  
  // MARK: - Race RaceEdition
  
  func insertEdition(_ edition: RaceEdition, to race: Race) throws {
    guard let context else { throw AppError.contextNotAttached }
    
    context.insert(edition)
    race.editions.append(edition)
  }
  
  func deleteEdition(_ edition: RaceEdition) throws {
    guard let context else { throw AppError.contextNotAttached }
    
    context.delete(edition)
  }
  
  // MARK: - Race Category
  
  func insertCategory(_ category: RaceCategory, to edition: RaceEdition) throws {
    guard let context else { throw AppError.contextNotAttached }
    
    context.insert(category)
    edition.categories.append(category)
  }
  
  func deleteCategory(_ category: RaceCategory) throws {
    guard let context else { throw AppError.contextNotAttached }
    
    context.delete(category)
  }
}
