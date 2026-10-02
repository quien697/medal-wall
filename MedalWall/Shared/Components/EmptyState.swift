//
//  EmptyState.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

struct EmptyState: View {
  let title: LocalizedStringKey
  let description: LocalizedStringKey

  var body: some View {
    ContentUnavailableView {
      Label(title, systemImage: "tray")
        .font(.TypeScale.title2)
        .foregroundStyle(Color.Text.primary)
    } description: {
      Text(description)
        .font(.TypeScale.body)
        .foregroundStyle(Color.Text.secondary)
    }  // ContentUnavailableView
  }
}

#Preview {
  EmptyState(title: "No Medals", description: "Tap the + button to add your first medal!")
}
