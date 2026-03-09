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
  
  func configure(context: ModelContext) {
    self.context = context
  }
  
  func save() throws {
    guard let context else { throw AppError.contextNotAttached }
    
    try context.save()
  }
  
  func insertUser(_ user: User) throws {
    guard let context else { throw AppError.contextNotAttached }
    
    context.insert(user)
  }
  
  func getUser() throws -> User? {
    guard let context else { throw AppError.contextNotAttached }
    
    let descriptor = FetchDescriptor<User>()
    return try context.fetch(descriptor).first
  }
}
