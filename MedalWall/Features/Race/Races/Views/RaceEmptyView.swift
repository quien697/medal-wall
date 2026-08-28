//
//  RaceEmptyView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

struct RaceEmptyView: View {
  var body: some View {
    ContentUnavailableView {
      Label("No Race evnets", systemImage: "tray")
        .font(.TypeScale.title2)
        .foregroundStyle(Color.Text.primary)
    } description: {
      Text("Tap the + button to add your first race event!")
        .font(.TypeScale.body)
        .foregroundStyle(Color.Text.secondary)
    }  // ContentUnavailableView
  }
}

#Preview {
  MedalEmptyView()
}
