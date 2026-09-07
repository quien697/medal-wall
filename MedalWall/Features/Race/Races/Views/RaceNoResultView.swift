//
//  RaceNoResultView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

struct RaceNoResultView: View {
  let searchText: String

  var body: some View {
    ContentUnavailableView {
      Label("No Results", systemImage: "magnifyingglass")
        .font(.TypeScale.title2)
        .foregroundStyle(Color.Text.primary)
    } description: {
      Text("No race evnets match '\(searchText)'")
        .font(.TypeScale.body)
        .foregroundStyle(Color.Text.secondary)
    }  // ContentUnavailableView
  }
}

#Preview {
  RaceNoResultView(searchText: "Taipei")
}
