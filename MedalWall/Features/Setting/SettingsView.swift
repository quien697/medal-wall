//
//  SettingsView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-02.
//

import SwiftUI

struct SettingsView: View {
  @Environment(UserManager.self) private var userManager
  @AppStorage(AppTheme.storageKey) private var appTheme: AppTheme = .system
  @AppStorage(AppLanguage.storageKey) private var appLanguage: AppLanguage = .system
  @AppStorage(DistanceUnit.storageKey) private var distanceUnit: DistanceUnit = .deviceDefault

  var body: some View {
    List {
      Section {
        AppearancePicker(appTheme: $appTheme)

        LanguagePicker(appLanguage: $appLanguage)

        DistanceUnitPicker(distanceUnit: $distanceUnit)
      } header: {
        Text("Preferences")
          .sectionTitleStyle()
      } footer: {
        Text(
          """
          Distance sets the pace unit (/km or /mi) and the starting unit for a custom \
          distance. Distances always show as they were entered.
          """
        )
        .font(.TypeScale.caption)
        .foregroundStyle(Color.Text.secondary)
      }  // Section
      .listRowBackground(Color.Surface.primary)

      Section {
        Button("Sign out") {
          try? userManager.signOut()
        }  // Button
        .actionStyle(.plain, shape: .roundedRectangle)
      }  // Section
      .listRowBackground(Color.Surface.primary)
      .listRowInsets(.all, 0)
    }  // List
    .navigationTitle("Settings")
    .toolbarTitleDisplayMode(.inline)
    .scrollContentBackground(.hidden)
    .background(Color.Background.primary)
  }
}

#Preview {
  NavigationStack {
    SettingsView()
  }  // NavigationStack
  .environment(UserManager())
}
