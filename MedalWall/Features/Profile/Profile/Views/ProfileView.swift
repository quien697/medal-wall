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
  @State private var isPresentingSettingsView = false
  // MARK: - Namespace
  @Namespace private var namespace
  private let settings: String = "settings"
  // MARK: - Query
  @Query private var medals: [Medal]
  
  var body: some View {
    NavigationStack {
      VStack {
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
          .scrollIndicators(.hidden)
          .navigationTitle("Profile")
          .background(Color.Background.primary)
          .toolbarTitleDisplayMode(.inlineLarge)
          .toolbarRole(.editor)
          .toolbar {
            ToolbarItem(placement: .title) {
              ExpandedNavigationTitle(title: "Profile")
            }

//            ToolbarItem(placement: .topBarTrailing) {
//              Button {
//                isPresentingSettingsView = true
//              } label: {
//                Image(systemName: "gearshape")
//              }
//              .matchedTransitionSource(id: settings, in: namespace)
//            }
            
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
        } else {
          NoProfileView()
        }
      } // VStack
      .sheet(isPresented: $isPresentingEditProfile) {
        if let user = userManager.currentUser {
          EditProfileView(mode: .edit, profile: user)
        } else {
          NoProfileView()
        }
      }
      .sheet(isPresented: $isPresentingSettingsView) {
        SettingsView()
          .navigationTransition(.zoom(sourceID: settings, in: namespace))
      }
    } // NavigationStack
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Environment(\.modelContext) var modelContext
  
  ProfileView()
    .environment(UserManager(modelContext: modelContext))
}
