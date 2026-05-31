//
//  MedalWallApp.swift
//  MedalWall
//
//  Created by Quien on 2025-10-20.
//

import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import SwiftUI

@main
struct MedalWallApp: App {
  @Environment(\.scenePhase) private var scenePhase
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
  @AppStorage("appTheme") private var appTheme: AppTheme = .system
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
      .preferredColorScheme(appTheme.colorScheme)
      .onOpenURL { url in
        GIDSignIn.sharedInstance.handle(url)
        if Auth.auth().isSignIn(withEmailLink: url.absoluteString) {
          Task {
            await userManager?.handleEmailLink(url.absoluteString)
          }
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

class AppDelegate: NSObject, UIApplicationDelegate {

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    let isTesting = ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil
    if !isTesting {
      FirebaseApp.configure()
    }

    return true
  }
}
