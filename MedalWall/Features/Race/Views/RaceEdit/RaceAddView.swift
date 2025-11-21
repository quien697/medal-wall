//
//  RaceAddView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
//

import SwiftUI
import SwiftData

struct RaceAddView: View {
  var body: some View {
    NavigationStack {
      RaceEditView(race: nil)
    }
  }
}

#Preview(traits: .sampleData) {
  RaceAddView()
}
