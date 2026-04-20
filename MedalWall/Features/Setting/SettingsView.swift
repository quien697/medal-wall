//
//  SettingsView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-02.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  
  @AppStorage("appTheme") private var appTheme: AppTheme = .system

  var body: some View {
    NavigationStack {
      List {
        Section {
          AppearancePicker(appTheme: $appTheme)
        } header: {
          Text("Preferences")
            .sectionTitleStyle()
        } // Section
      } // List
      .navigationTitle("Settings")
      .toolbarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  SettingsView()
}
