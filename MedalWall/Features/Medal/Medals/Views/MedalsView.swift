//
//  MedalsView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI

struct MedalsView: View {
  // MARK: - Environment
  @Environment(UserManager.self) private var userManager

  // MARK: - State
  @State private var viewModel = MedalsViewModel()
  /// Lays the skeleton out from placeholder medals, through the same view model the
  /// collection uses.
  @State private var placeholderViewModel: MedalsViewModel = {
    let viewModel = MedalsViewModel()
    viewModel.medals = Medal.placeholders
    return viewModel
  }()
  @State private var errorWrapper: ErrorWrapper?
  @State private var isPresentingAddMedal = false

  // MARK: - Namespace
  @Namespace private var namespace
  private let addMedal: String = "addMedal"

  // MARK: - Body
  var body: some View {
    NavigationStack {
      MedalList(viewModel: viewModel.isShowingSkeleton ? placeholderViewModel : viewModel)
        .skeleton(viewModel.isShowingSkeleton)
        .navigationTitle("Your Collection")
        .background(Color.Background.primary)
        .toolbarTitleDisplayMode(.inlineLarge)
        .toolbarRole(.editor)
        .toolbar {
          ToolbarItem(placement: .title) {
            ExpandedNavigationTitle(title: "Your Collection")
          }  // ToolbarItem

          ToolbarItem(placement: .topBarTrailing) {
            Button {
              isPresentingAddMedal = true
            } label: {
              Image(systemName: "plus")
            }  // Button
            .matchedTransitionSource(id: addMedal, in: namespace)
            .buttonStyle(.glassProminent)
          }  // ToolbarItem
        }  // toolbar
        .onAppear {
          guard let userId = userManager.currentUserID else { return }
          Task { await viewModel.loadMedals(userId: userId) }
        }
        .sheet(
          isPresented: $isPresentingAddMedal,
          onDismiss: {
            guard let userId = userManager.currentUserID else { return }
            Task { await viewModel.loadMedals(userId: userId) }
          },
          content: {
            AddMedalView()
              .navigationTransition(.zoom(sourceID: addMedal, in: namespace))
          }
        )
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
    }  // NavigationStack
  }
}

#Preview("Loading") {
  MedalsView()
    .environment(UserManager())
}
