//
//  MedalWallApp.swift
//  MedalWall
//
//  Created by Quien on 2025-10-20.
//

import SwiftUI
import SwiftData

@main
struct MedalWallApp: App {
  var sharedModelContainer: ModelContainer = {
    let schema = Schema([
      User.self,
//      Race.self,
//      RaceCategory.self,
//      Medal.self,
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

    do {
      let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
      let context = ModelContext(container)
      try DefaultDataSeeder.seed(in: context)
      
      return container
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  var body: some Scene {
    WindowGroup {
      ContentView()
    }
    .modelContainer(sharedModelContainer)
  }
}
