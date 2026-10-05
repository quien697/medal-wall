//
//  ProfileUnavailableView.swift
//  MedalWall
//
//  Created by Quien on 2026-10-03.
//

import SwiftUI

/// Stands in for the app while a signed-in user's profile can't load, and always offers a
/// way out by signing out.
struct ProfileUnavailableView: View {
  // MARK: - Environment
  @Environment(UserManager.self) private var userManager

  // MARK: - Properties
  let title: LocalizedStringKey
  let description: LocalizedStringKey
  let systemImage: String
  /// Shown as a Try Again button when set; left out while the app retries by itself.
  var onRetry: (() async -> Void)?

  // MARK: - Body
  var body: some View {
    EmptyState(title: title, description: description, systemImage: systemImage) {
      if let onRetry {
        Button("Try Again") {
          Task { await onRetry() }
        }
        .actionStyle(.primary)
      }

      Button("Sign out") {
        try? userManager.signOut()
      }
      .actionStyle(.plain)
    }  // EmptyState
    .background(Color.Background.primary)
  }
}

#Preview("Waiting for a Connection") {
  ProfileUnavailableView(
    title: "Waiting for a Connection",
    description: "Your profile will load as soon as you're back online.",
    systemImage: "wifi.slash"
  )
  .environment(UserManager())
}

#Preview("Couldn't Load") {
  ProfileUnavailableView(
    title: "Couldn't Load Your Profile",
    description: "Something went wrong while loading your profile.",
    systemImage: "exclamationmark.triangle",
    onRetry: {}
  )
  .environment(UserManager())
}
