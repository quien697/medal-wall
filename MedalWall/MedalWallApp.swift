//
//  MedalWallApp.swift
//  MedalWall
//
//  Created by Quien on 2025-10-20.
//

import SwiftUI
import SwiftData
import FirebaseCore

@main
struct MedalWallApp: App {
  @Environment(\.scenePhase) private var scenePhase
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @AppStorage("appTheme") private var appTheme: AppTheme = .system
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
          if userManager.isLoggedIn {
            TempView()
          } else {
            LoginView()
          }
        } else {
          LoadingView(text: "Loading...")
        }
      } // Group
      .environment(userManager)
      .preferredColorScheme(appTheme.colorScheme)
      .task {
        guard userManager == nil else { return }
        
        let context = ModelContext(sharedModelContainer)
        userManager = UserManager(modelContext: context)
      }
    } // WindowGroup
    .modelContainer(sharedModelContainer)
    .onChange(of: scenePhase) { _, newPhase in
      if newPhase == .active {
        Task {
          await userManager?.validateSession()
        }
      }
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()
    
    return true
  }
}
