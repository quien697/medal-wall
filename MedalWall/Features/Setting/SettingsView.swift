//
//  SettingsView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-02.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss
  @Environment(UserManager.self) private var userManager

  // MARK: - State
  @AppStorage("appTheme") private var appTheme: AppTheme = .system

  // MARK: - Body
  var body: some View {
    NavigationStack {
      List {
        Section {
          AppearancePicker(appTheme: $appTheme)
        } header: {
          Text("Preferences")
            .sectionTitleStyle()
        } // Section

        Section {
          Button {
            try? userManager.signOut()
          } label: {
            Text("Sign out")
              .frame(maxWidth: .infinity)
          }
          .goldOutLineButtonStyle(vPadding: 12)
        } // Section
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listSectionSpacing(16)
        .listRowInsets(.all, 0)
      } // List
      .navigationTitle("Settings")
      .toolbarTitleDisplayMode(.inline)
    }
  }
}

#Preview {
  SettingsView()
    .environment(UserManager())
}
