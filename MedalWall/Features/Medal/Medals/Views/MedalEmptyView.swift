//
//  MedalEmptyView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-16.
//

import SwiftUI

struct MedalEmptyView: View {

  var body: some View {
    ContentUnavailableView(
      "No Medals",
      systemImage: "tray",
      description: Text("Tap the + button to add your first medal!")
    )
  }
}

#Preview {
  MedalEmptyView()
}
