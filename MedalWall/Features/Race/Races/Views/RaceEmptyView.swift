//
//  RaceEmptyView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

struct RaceEmptyView: View {
  
  var body: some View {
    ContentUnavailableView(
      "No Race evnets",
      systemImage: "tray",
      description: Text("Tap the + button to add your first race event!")
    )
  }
}

#Preview {
  MedalEmptyView()
}
