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
    if try context.fetch(FetchDescriptor<User>()).isEmpty {
      try insertDefaultUser(in: context)
    }
    if try context.fetch(FetchDescriptor<Race>()).isEmpty {
      try insertDefaultRaces(in: context)
    }
    if try context.fetch(FetchDescriptor<Medal>()).isEmpty {
      try insertDefaultMedals(in: context)
    }
    
    try context.save()
  }
  
  private static func insertDefaultUser(in context: ModelContext) throws {
    context.insert(User.guest)
  }
  
  private static func insertDefaultRaces(in context: ModelContext) throws {
    Race.sampleData.forEach { context.insert($0) }
  }
  
  private static func insertDefaultMedals(in context: ModelContext) throws {
    Medal.sampleData.forEach { context.insert($0) }
  }
}
