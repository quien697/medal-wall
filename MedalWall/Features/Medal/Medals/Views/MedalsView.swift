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
  @State private var errorWrapper: ErrorWrapper?
  @State private var isPresentingAddMedal = false

  // MARK: - Namespace
  @Namespace private var namespace
  private let addMedal: String = "addMedal"

  // MARK: - Body
  var body: some View {
    NavigationStack {
      Group {
        if viewModel.medals.isEmpty && !viewModel.isLoading {
          MedalEmptyView()
        } else {
          ScrollView {
            MedalStatsSection(
              totalCount: viewModel.totalCount,
              fullCount: viewModel.fullCount,
              halfCount: viewModel.halfCount
            )

            MedalGridSection(
              medals: viewModel.medals,
              columns: viewModel.gridColumns,
              spacing: viewModel.gridSpacing,
              namespace: namespace
            )
          }  // ScrollView
          .scrollIndicators(.hidden)
        }
      }  // Group
      .navigationTitle("Your Rewards")
      .background(Color.Background.primary)
      .toolbarTitleDisplayMode(.inlineLarge)
      .toolbarRole(.editor)
      .overlay {
        if viewModel.isLoading {
          ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.1))
        }
      }
      .toolbar {
        ToolbarItem(placement: .title) {
          ExpandedNavigationTitle(title: "Your Rewards")
        }

        ToolbarItem(placement: .topBarTrailing) {
          Button {
            isPresentingAddMedal = true
          } label: {
            Image(systemName: "plus")
          }
          .matchedTransitionSource(id: addMedal, in: namespace)
          .buttonStyle(.glassProminent)
        }
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

#Preview {
  MedalsView()
    .environment(UserManager())
}
