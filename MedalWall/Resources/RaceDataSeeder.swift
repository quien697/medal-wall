//
//  RaceDataSeeder.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation
import SwiftData

enum RaceDataSeeder {
  
  static func insertDefaultData(into container: ModelContainer) {
    let context = ModelContext(container)
    
    do {
      let existing = try context.fetch(FetchDescriptor<Race>())
      guard existing.isEmpty else {
        print("✅ Default data already exists, skipping seeding.")
        return
      }
      
      let user = DefaultUsers.demo
      context.insert(user)
      
      let races = DefaultRaces.all()
      races.forEach { context.insert($0) }
      
      let medals = DefaultMedals.all(for: user, races: races)
      medals.forEach { context.insert($0) }
      
      try context.save()
      print("✅ Default data (User, Races, Medals) inserted.")
    } catch {
      print("❌ Failed to insert default data: \(error)")
    }
  }
}
