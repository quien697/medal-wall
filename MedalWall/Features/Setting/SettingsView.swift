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

        Section {
          Button {
            try? userManager.signOut()
          } label: {
            Text("Sign out")
              .frame(maxWidth: .infinity)
          }
          .actionStyle(.secondary)
        }  // Section
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(.all, 3)
      }  // List
      .navigationTitle("Settings")
      .toolbarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  SettingsView()
    .environment(UserManager())
}
