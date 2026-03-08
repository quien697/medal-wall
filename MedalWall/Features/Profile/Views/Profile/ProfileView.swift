//
//  ProfileView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
  @Environment(UserManager.self) private var userManager
  @State private var isShowingProfileAddView = false
  @State private var isShowingSettingsView = false
  
  var body: some View {
    Group {
      if let user = userManager.currentUser {
        ScrollView {
          ProfileHeaderSection(
            avatar: user.avatar,
            cropAvatar: user.cropAvatar,
            userName: user.fullName,
            bio: user.bio
          )
          
          ProfileSummarySection()
          
          ProfileAchievementsSection()
            .padding(.bottom, 10)
        } // ScrollView
        .navigationTitle("Profile")
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button("Settings", systemImage: "gearshape.fill") {
              isShowingSettingsView = true
            }
          }
        } // toolbar
      } else {
        ContentUnavailableView {
          Label("No User Found", systemImage: "person.fill")
        } description: {
          Button {
            isShowingProfileAddView = true
          } label: {
            Text("Creating a new user")
              .padding(.top, 10)
          }
        } // ContentUnavailableView
      }
    } // Group
    .background(Color.Background.primary)
    .sheet(isPresented: $isShowingProfileAddView) {
      NavigationStack {
        ProfileAddView()
      }
    }
    .sheet(isPresented: $isShowingSettingsView) {
      NavigationStack{
        SettingsView()
      }
    }
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Environment(\.modelContext) var modelContext
  
  ProfileView()
    .environment(UserManager(modelContext: modelContext))
}
