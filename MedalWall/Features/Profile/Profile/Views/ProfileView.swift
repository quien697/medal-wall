//
//  ProfileView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
  // MARK: - Environment
  @Environment(UserManager.self) private var userManager
  // MARK: - State
  @State private var viewModel = ProfileViewModel()
  @State private var isShowingProfileAddView = false
  @State private var isShowingSettingsView = false
  // MARK: - Query
  @Query private var medals: [Medal]
  
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
          
          ProfileSummarySection(
            totalMedals: viewModel.totalMedals(medals),
            bestFullTime: viewModel.bestFullTime(medals),
            bestHalfTime: viewModel.bestHalfTime(medals)
          )
          
          //          ProfileAchievementsSection()
            .padding(.bottom, 10)
        } // ScrollView
        .navigationTitle("Profile")
        .background(Color.Background.primary)
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
        .background(Color.Background.primary)
      }
    } // Group
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
