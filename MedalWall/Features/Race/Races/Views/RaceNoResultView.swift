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
    } description: {
      Text("No race evnets match '\(searchText)'")
    }
  }
}

#Preview {
  RaceNoResultView(searchText: "Taipei")
}
