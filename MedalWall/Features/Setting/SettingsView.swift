//
//  SettingsView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-02.
//

import SwiftUI

struct SettingsView: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss
  @Environment(UserManager.self) private var userManager

  // MARK: - State
  @AppStorage("appTheme") private var appTheme: AppTheme = .system
  @AppStorage(AppLanguage.storageKey) private var appLanguage: AppLanguage = .system
  @AppStorage(DistanceUnit.storageKey) private var distanceUnit: DistanceUnit = .deviceDefault

  // MARK: - Body
  var body: some View {
    NavigationStack {
      List {
        Section {
          AppearancePicker(appTheme: $appTheme)

          LanguagePicker(appLanguage: $appLanguage)

          DistanceUnitPicker(distanceUnit: $distanceUnit)
        } header: {
          Text("Preferences")
            .sectionTitleStyle()
        }  // Section
        .listRowBackground(Color.Surface.primary)

        Section {
          Button("Sign out") {
            try? userManager.signOut()
          }
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
}

#Preview {
  SettingsView()
    .environment(UserManager())
}
