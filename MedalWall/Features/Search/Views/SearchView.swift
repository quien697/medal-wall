//
//  SearchView.swift
//  MedalWall
//
//  Created by Quien on 2026-10-25.
//

import SwiftUI

/// The Search tab: one field that finds the user's medals and any race.
///
/// An empty field shows a hint. Once something is typed the results update on every
/// keystroke; until the first loads finish, a query that matches nothing yet shows an empty
/// page rather than "No Results".
struct SearchView: View {
  @Environment(UserManager.self) private var userManager
  @State private var viewModel = SearchViewModel()
  @State private var errorWrapper: ErrorWrapper?

  var body: some View {
    NavigationStack {
      Group {
        if viewModel.isQueryEmpty {
          EmptyState(
            title: "Search Races and Medals",
            description: "Find any race by name, city or country.",
            systemImage: "magnifyingglass"
          )
        } else if viewModel.isShowingNoResults {
          ContentUnavailableView.search(text: viewModel.query)
        } else {
          SearchResultList(
            medals: viewModel.matchingMedals,
            races: viewModel.matchingRaces,
            personalRecordIDs: viewModel.personalRecordIDs
          )
        }
      }  // Group
      .scrollIndicators(.hidden)
      .navigationTitle("Search")
      .background(Color.Background.primary)
      .toolbarTitleDisplayMode(.inlineLarge)
      .toolbarRole(.editor)
      .toolbar {
        ToolbarItem(placement: .title) {
          ExpandedNavigationTitle(title: "Search")
        }  // ToolbarItem
      }  // toolbar
      .searchable(text: $viewModel.searchText, prompt: "Search races and medals")
      .autocorrectionDisabled()
      .onAppear {
        Task { await viewModel.load(userId: userManager.currentUserID) }
      }
      .onChange(of: viewModel.error) { _, error in
        if let error {
          errorWrapper = ErrorWrapper(error: error)
        }
      }
      .sheet(
        item: $errorWrapper,
        onDismiss: { viewModel.error = nil },
        content: { wrapper in
          ErrorView(errorWrapper: wrapper)
        }
      )  // sheet
    }  // NavigationStack
  }
}

#Preview("Hint") {
  SearchView()
    .environment(UserManager())
}
