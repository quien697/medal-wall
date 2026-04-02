//
//  ContentView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-20.
//

import SwiftUI

struct ContentView: View {
  @State private var selection: Tab = .profile
  
  enum Tab {
    case profile
    case medal
    case race
  }
  
  var body: some View {
    TabView(selection: $selection) {
      NavigationStack {
        ProfileView()
      }
      .tabItem {
        Label("You", systemImage: "person.crop.circle")
      }
      .tag(Tab.profile)
      
      NavigationStack {
        MedalsView()
      }
      .tabItem {
        Label("Medal", systemImage: "medal")
      }
      .tag(Tab.medal)
      
      NavigationStack {
        RacesView()
      }
      .tabItem {
        Label("Race", systemImage: "figure.run")
      }
      .tag(Tab.race)
    }
  }
}

#Preview {
  ContentView()
}
