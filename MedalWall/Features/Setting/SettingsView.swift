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
  @Environment(UserManager.self) private var userManager
  
  var body: some View {
    List {
      Section {
        if let user = userManager.currentUser {
          NavigationLink {
            ProfileEditView(profile: user)
          } label: {
            HStack {
              AvatarImage(
                photo: user.avatar,
                cropPhoto: user.cropAvatar,
                imageType: .avatarThumbnail
              )
              
              VStack(alignment: .leading) {
                Text(user.fullName)
                  .fontWeight(.bold)
                
                Text("@zxcvbn")
                  .foregroundStyle(Color.Text.tertiary)
              }
            }
          }
        } else {
          ContentUnavailableView {
            Text("No User Found")
          }
        }
      } header: {
        Text("Account")
          .sectionTitleStyle()
      }
      
      Section {
        NavigationLink("Units of Measure") { }
        
        NavigationLink("Pace Format") { }
        
        NavigationLink("Apperance") { }
      } header: {
        Text("Preferences")
          .sectionTitleStyle()
      }
      
      Section {
        Toggle(isOn: .constant(true)) {
          Text("Race Reminders")
        }
      } header: {
        Text("Notifications")
          .sectionTitleStyle()
      }
      
    }
    .navigationTitle("Settings")
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Environment(\.modelContext) var modelContext
  
  SettingsView()
    .environment(UserManager(modelContext: modelContext))
}
