//
//  SettingsView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-02.
//

import SwiftUI

struct SettingsView: View {
  @Environment(\.dismiss) private var dismiss
  
  var body: some View {
    List {
      NavigationLink("Profile Settings") {
        ProfileEditView()
      }
      
      NavigationLink("Account Settings") {
        AccountSettingsView()
      }
    }
    .navigationTitle("Settings")
  }
}

#Preview {
  SettingsView()
}
