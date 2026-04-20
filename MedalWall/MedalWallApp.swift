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
  @State private var userManager: UserManager?
  
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
      return try ModelContainer(for: schema, configurations: [modelConfiguration])
    } catch {
      fatalError("Could not create ModelContainer: \(error)")
    }
  }()
  
  var body: some Scene {
    WindowGroup {
      Group {
        if let userManager {
          if userManager.currentUser != nil {
            ContentView()
          } else {
            LoginView()
          }
        } else {
          LoadingView(text: "Loading...")
        }
      } // Group
      .environment(userManager)
      .task {
        guard userManager == nil else { return }
        
        let context = ModelContext(sharedModelContainer)
        userManager = UserManager(modelContext: context)
      }
    } // WindowGroup
    .modelContainer(sharedModelContainer)
  }
}
