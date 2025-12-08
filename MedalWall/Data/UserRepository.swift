//
//  UserRepository.swift
//  MedalWall
//
//  Created by Quien on 2025-12-04.
//

import Foundation
import SwiftData

final class UserRepository {
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
  
  func insertUser(_ profile: User) throws {
    guard let context else { throw AppError.contextNotAttached }
    context.insert(profile)
  }
}
