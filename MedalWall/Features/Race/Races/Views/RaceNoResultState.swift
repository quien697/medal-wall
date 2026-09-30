//
//  RaceNoResultState.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

struct RaceNoResultState: View {
  let searchText: String

  var body: some View {
    ContentUnavailableView {
      Label("No Results", systemImage: "magnifyingglass")
        .font(.TypeScale.title2)
        .foregroundStyle(Color.Text.primary)
    } description: {
      Text("No race events match '\(searchText)'")
        .font(.TypeScale.body)
        .foregroundStyle(Color.Text.secondary)
    }  // ContentUnavailableView
  }
}

#Preview {
  RaceNoResultState(searchText: "Taipei")
}
