//
//  ProfileView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
  @State private var isShowingProfileAddView = false
  @State private var isShowingSettingsView = false
  
  @Query private var users: [User]
  
  private var user: User? { users.first }
  
  var body: some View {
    Group {
      if let user {
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
    //    .sheet(isPresented: $isShowingProfileAddView) {
    //      NavigationStack {
    //        ProfileAddView()
    //      }
    //    }
    .background(Color.backgroundPrimary)
    .sheet(isPresented: $isShowingSettingsView) {
      NavigationStack{
        SettingsView()
      }
    }
  }
}

#Preview(traits: .sampleData) {
  ProfileView()
}
