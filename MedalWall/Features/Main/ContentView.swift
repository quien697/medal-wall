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
      }  // Tab

      Tab("Medal", systemImage: "medal") {
        MedalsView()
      }  // Tab

      Tab("Race", systemImage: "figure.run") {
        RacesView()
      }  // Tab
    }  // TabView
  }
}

#Preview {
  ContentView()
    .environment(UserManager())
}
