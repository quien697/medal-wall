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
      Race.self,
      RaceEdition.self,
      RaceCategory.self,
      Medal.self,
      EventPhoto.self
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
  
  @State private var userManager: UserManager?
  
  var body: some Scene {
    WindowGroup {
      Group {
        if let userManager {
          ContentView()
            .environment(userManager)
        } else {
          VStack(spacing: 20) {
            ProgressView()
            Text("Loading...")
          }
        }
      }
      .onAppear {
        guard userManager == nil else { return }
        
        let context = ModelContext(sharedModelContainer)
        userManager = UserManager(modelContext: context)
      }
    }
    .modelContainer(sharedModelContainer)
  }
}
