//
//  ProfileLoadingView.swift
//  MedalWall
//
//  Created by Quien on 2026-10-05.
//

import SwiftUI

/// Shown while a signed-in user's profile loads — the place a skeleton of the app can replace
/// the spinner later. Sign out fades in if loading takes a while, so nobody is stuck when it
/// can't finish, without flashing on a load that does.
struct ProfileLoadingView: View {
  @Environment(UserManager.self) private var userManager
  @State private var isSignOutVisible = false

  var body: some View {
    VStack(spacing: 24) {
      LoadingView(text: "Loading...")

      Button("Sign out") {
        try? userManager.signOut()
      }
      .actionStyle(.plain)
      .opacity(isSignOutVisible ? 1 : 0)
      .disabled(!isSignOutVisible)
    }  // VStack
    .task {
      try? await Task.sleep(for: .seconds(3))
      withAnimation { isSignOutVisible = true }
    }
  }
}

#Preview {
  ProfileLoadingView()
    .environment(UserManager())
}
