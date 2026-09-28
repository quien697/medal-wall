//
//  MedalWallApp.swift
//  MedalWall
//
//  Created by Quien on 2025-10-20.
//

import FirebaseCore
import SwiftUI

@main
struct MedalWallApp: App {
  @Environment(\.scenePhase) private var scenePhase
  @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
  @AppStorage(AppTheme.storageKey) private var appTheme: AppTheme = .system
  @AppStorage(AppLanguage.storageKey) private var appLanguage: AppLanguage = .system
  @AppStorage(DistanceUnit.storageKey) private var distanceUnit: DistanceUnit = .deviceDefault
  @State private var userManager: UserManager?

  var body: some Scene {
    WindowGroup {
      Group {
        if let userManager, !userManager.isLoadingAuth {
          if userManager.isLoggedIn {
            ContentView()
          } else {
            LoginView()
          }
        } else {
          LoadingView(text: "Loading...")
        }
      }  // Group
      .environment(userManager)
      .environment(\.locale, appLanguage.resolvedLocale)
      .id("\(appLanguage.rawValue)-\(distanceUnit.rawValue)")
      .preferredColorScheme(appTheme.colorScheme)
      .onOpenURL { url in
        Task {
          await userManager?.handleOpenURL(url)
        }
      }
      .task {
        guard userManager == nil else { return }
        userManager = UserManager()
      }
    }  // WindowGroup
    .onChange(of: scenePhase) { _, newPhase in
      if newPhase == .active {
        Task {
          await userManager?.validateSession()
        }
      }
    }
  }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
  /// Configures Firebase before anything touches it.
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    FirebaseApp.configure()

    return true
  }
}
