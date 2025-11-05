//
//  DefaultDataSeeder.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation
import SwiftData

enum DefaultDataSeeder {
  
  static func seed(in context: ModelContext) throws {
    try insertDefaultUser(in: context)
    try insertDefaultRaces(in: context)
    try insertDefaultMedals(in: context)
  }
  
  private static func insertDefaultUser(in context: ModelContext) throws {
    do {
      let existing = try context.fetch(FetchDescriptor<User>())
      guard existing.isEmpty else { return }
      
      context.insert(User.defaultUser)
      try context.save()
      print("Default user inserted.")
    } catch {
      print("Failed to insert default user data: \(error)")
    }
  }
  
  private static func insertDefaultRaces(in context: ModelContext) throws {
    do {
      let existing = try context.fetch(FetchDescriptor<Race>())
      guard existing.isEmpty else { return }
      
      Race.sampleData.forEach { context.insert($0) }
      try context.save()
      print("Default races inserted.")
    } catch {
      print("Failed to insert default races data: \(error)")
    }
  }
  
  private static func insertDefaultMedals(in context: ModelContext) throws {
    do {
      let existing = try context.fetch(FetchDescriptor<Medal>())
      guard existing.isEmpty else { return }
      
      Medal.sampleData.forEach { context.insert($0) }
      try context.save()
      print("Default medals inserted.")
    } catch {
      print("Failed to insert default medals data: \(error)")
    }
  }
}
