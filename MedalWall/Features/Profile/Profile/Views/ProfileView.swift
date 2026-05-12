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
  @State private var isPresentingEditProfile = false
  // MARK: - Query
  @Query private var medals: [Medal]
  
  // MARK: - Body
  var body: some View {
    NavigationStack {
      ScrollView {
        ProfileHeaderSection(
          photoUrl: userManager.currentUser?.photoUrl,
          userName: userManager.currentUserName,
          bio: userManager.currentUser?.bio
        )
        
        ProfileSummarySection(
          totalMedals: viewModel.totalMedals(medals),
          fullCount: viewModel.fullCount(medals),
          halfCount: viewModel.halfCount(medals),
          bestFullTime: viewModel.bestFullTime(medals),
          bestHalfTime: viewModel.bestHalfTime(medals)
        )
        
        .padding(.bottom, 10)
      } // ScrollView
      .scrollIndicators(.hidden)
      .navigationTitle("Profile")
      .background(Color.Background.primary)
      .toolbarTitleDisplayMode(.inlineLarge)
      .toolbarRole(.editor)
      .toolbar {
        ToolbarItem(placement: .title) {
          ExpandedNavigationTitle(title: "Profile")
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          NavigationLink {
            SettingsView()
          } label: {
            Image(systemName: "gearshape")
          }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Menu {
            Button {
              isPresentingEditProfile = true
            } label: {
              Label("Edit Profile", systemImage: "square.and.pencil")
            }
          } label: {
            Image(systemName: "ellipsis")
          }
        }
      } // toolbar
      .sheet(isPresented: $isPresentingEditProfile) {
        if let user = userManager.currentUser {
          EditProfileView(profile: user)
        }
      }
    } // NavigationStack
  }
}

#Preview(traits: .sampleData) {
  ProfileView()
    .environment(UserManager())
}
