//
//  RaceDistanceAddView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-10.
//

import SwiftUI
import SwiftData

struct RaceDistanceAddView: View {
  let onSave: (RaceDistance) -> Void
  
  var body: some View {
    NavigationStack {
      RaceDistanceEditView(
        mode: .add,
        distance: .default,
        onSave: onSave
      )
    }
  }
}

#Preview(traits: .sampleData) {
  NavigationStack{
    RaceDistanceAddView(onSave: { _ in print("onSave") })
  }
}
