//
//  ProfileView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI

struct ProfileView: View {
  // MARK: - Environment
  @Environment(UserManager.self) private var userManager

  // MARK: - State
  @State private var viewModel = ProfileViewModel()
  @State private var isPresentingEditProfile = false
  @State private var errorWrapper: ErrorWrapper?

  // MARK: - Body
  var body: some View {
    NavigationStack {
      Group {
        if userManager.currentUser == nil, userManager.profileLoadError != nil {
          EmptyState(
            title: "Profile Unavailable",
            description:
              "We couldn't load your profile. Please check your connection and try again."
          )
        } else {
          ScrollView {
            let user = userManager.currentUser ?? .placeholder
            ProfileHeaderSection(photoUrl: user.photoUrl, userName: user.name, bio: user.bio)
              .skeleton(userManager.isProfileLoading)

            ProfileSummarySection(
              totalMedals: viewModel.totalMedals,
              fullCount: viewModel.fullCount,
              halfCount: viewModel.halfCount,
              bestFullTime: viewModel.bestFullTime,
              bestHalfTime: viewModel.bestHalfTime,
              isShowingSkeleton: viewModel.isShowingSkeleton
            )

            ProfileAchievementsSection(
              fullMarathonProgress: viewModel.fullMarathonProgress,
              halfMarathonProgress: viewModel.halfMarathonProgress,
              isShowingSkeleton: viewModel.isShowingSkeleton
            )
            .padding(.bottom, 10)
          }  // ScrollView
          .scrollIndicators(.hidden)
        }
      }  // Group
      .navigationTitle("Profile")
      .background(Color.Background.primary)
      .toolbarTitleDisplayMode(.inlineLarge)
      .toolbarRole(.editor)
      .onAppear {
        guard let userId = userManager.currentUserID else { return }
        Task { await viewModel.loadMedals(userId: userId) }
      }
      .toolbar {
        ToolbarItem(placement: .title) {
          ExpandedNavigationTitle(title: "Profile")
        }  // ToolbarItem

        ToolbarItem(placement: .topBarTrailing) {
          NavigationLink {
            SettingsView()
          } label: {
            Image(systemName: "gearshape")
          }  // NavigationLink
        }  // ToolbarItem

        ToolbarItem(placement: .topBarTrailing) {
          Menu {
            Button {
              isPresentingEditProfile = true
            } label: {
              Label("Edit Profile", systemImage: "square.and.pencil")
            }  // Button
            .disabled(!userManager.canEditProfile)
          } label: {
            Image(systemName: "ellipsis")
          }  // Menu
        }  // ToolbarItem
      }  // toolbar
      .sheet(isPresented: $isPresentingEditProfile) {
        if let user = userManager.currentUser {
          EditProfileView(profile: user)
        }
      }
      .sheet(
        item: $errorWrapper,
        onDismiss: { viewModel.error = nil },
        content: { wrapper in
          ErrorView(errorWrapper: wrapper)
        }
      )
      .onChange(of: viewModel.error) { _, error in
        if let error {
          errorWrapper = ErrorWrapper(error: error)
        }
      }
      // Never cleared on dismiss: the error keeps the empty state up and is what the retry
      // on reconnect or return to the app looks for.
      .onChange(of: userManager.profileLoadError, initial: true) { _, error in
        if let error {
          errorWrapper = ErrorWrapper(error: error)
        }
      }
    }  // NavigationStack
  }
}

#Preview {
  ProfileView()
    .environment(UserManager())
}
