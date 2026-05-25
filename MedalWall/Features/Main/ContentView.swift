//
//  ContentView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-20.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    TabView {
      Tab("You", systemImage: "person.crop.circle") {
        ProfileView()
      }

      Tab("Medal", systemImage: "medal") {
        MedalsView()
      }

      Tab("Race", systemImage: "figure.run") {
        RacesView()
      }
    }
  }
}

#Preview {
  ContentView()
}
