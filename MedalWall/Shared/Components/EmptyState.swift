//
//  EmptyState.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

struct EmptyState<Actions: View>: View {
  // MARK: - Properties
  let title: LocalizedStringKey
  let description: LocalizedStringKey
  let systemImage: String
  private let actions: () -> Actions

  // MARK: - Init
  /// An empty state with buttons beneath its description.
  init(
    title: LocalizedStringKey,
    description: LocalizedStringKey,
    systemImage: String = "tray",
    @ViewBuilder actions: @escaping () -> Actions
  ) {
    self.title = title
    self.description = description
    self.systemImage = systemImage
    self.actions = actions
  }

  // MARK: - Body
  var body: some View {
    ContentUnavailableView {
      Label(title, systemImage: systemImage)
        .font(.TypeScale.title2)
        .foregroundStyle(Color.Text.primary)
    } description: {
      Text(description)
        .font(.TypeScale.body)
        .foregroundStyle(Color.Text.secondary)
    } actions: {
      actions()
    }  // ContentUnavailableView
  }
}

extension EmptyState where Actions == EmptyView {
  /// An empty state with nothing to act on.
  init(title: LocalizedStringKey, description: LocalizedStringKey, systemImage: String = "tray") {
    self.init(title: title, description: description, systemImage: systemImage) {
      EmptyView()
    }
  }
}

#Preview {
  EmptyState(title: "No Medals", description: "Tap the + button to add your first medal!")
}

#Preview("With Actions") {
  EmptyState(
    title: "Couldn't Load Your Profile",
    description: "Something went wrong while loading your profile.",
    systemImage: "exclamationmark.triangle"
  ) {
    Button("Try Again") {}
      .actionStyle(.primary)
  }
}
