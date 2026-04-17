//
//  AddRaceView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
//

import SwiftUI
import SwiftData

struct AddRaceView: View {
  var body: some View {
    NavigationStack {
      EditRaceView(mode: .add)
    }
  }
}

#Preview(traits: .sampleData) {
  AddRaceView()
}
